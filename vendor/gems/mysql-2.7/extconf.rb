require 'mkmf'

if mc = with_config('mysql-config') then
  mc = 'mysql_config' if mc == true
  cflags = `#{mc} --cflags`.chomp
  exit 1 if $? != 0
  libs = `#{mc} --libs`.chomp
  exit 1 if $? != 0
  $CPPFLAGS += ' ' + cflags
  $libs = libs + " " + $libs
else
  inc, lib = dir_config('mysql', '/usr/local')
  libs = ['m', 'z', 'socket', 'nsl']
  while not find_library('mysqlclient', 'mysql_query', lib, "#{lib}/mysql") do
    exit 1 if libs.empty?
    have_library(libs.shift)
  end
end

have_func('mysql_ssl_set')

if have_header('mysql.h') then
  src = "#include <errmsg.h>\n#include <mysqld_error.h>\n"
elsif have_header('mysql/mysql.h') then
  src = "#include <mysql/errmsg.h>\n#include <mysql/mysqld_error.h>\n"
else
  exit 1
end

# make mysql constant
File::open("conftest.c", "w") do |f|
  f.puts src
end
if defined? cpp_command then
  cpp = Config::expand(cpp_command(''))
else
  cpp = Config::expand sprintf(CPP, $CPPFLAGS, $CFLAGS, '')
end
unless system "#{cpp} > confout" then
  exit 1
end
File::unlink "conftest.c"

error_syms = []
IO::foreach('confout') do |l|
  next unless l =~ /errmsg\.h|mysqld_error\.h/
  fn = l.split(/\"/)[1]
  IO::foreach(fn) do |m|
    if m =~ /^#define\s+([CE]R_[0-9A-Z_]+)/ then
      error_syms << $1
    end
  end
end
File::unlink 'confout'
error_syms.uniq!

newf = File::open('mysql.c', 'w')
IO::foreach('mysql.c.in') do |l|
  newf.puts l
  if l =~ /\/\* Mysql::Error constant \*\// then
    error_syms.each do |s|
      newf.puts "    rb_define_const(eMysql, \"#{s}\", INT2NUM(#{s}));"
    end
  end
end

create_makefile("mysql")
