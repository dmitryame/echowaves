require 'termios'

def dump_termios(tio, banner)
  puts banner
  puts "  ispeed = #{Termios::BAUDS[tio.ispeed]}, ospeed = #{Termios::BAUDS[tio.ospeed]}"
  ["iflag", "oflag", "cflag", "lflag"].each do |x|
    flag = tio.send(x)
    flags = []
    eval("Termios::#{x.upcase}S").each do |f, sym|
      flags << sym.to_s if flag & f != 0
    end
    puts "   #{x} = #{flags.sort.join(' | ')}"
  end
  print "      cc ="
  cc = tio.cc
  cc.each_with_index do |x, idx|
    print " #{Termios::CCINDEX[idx]}=#{x}" if Termios::CCINDEX.include?(idx)
  end
  puts
end

tio = Termios::getattr($stdin)
dump_termios(tio, "STDIN:")
Termios::setattr($stdin, Termios::TCSANOW, tio)
dump_termios(tio, "STDIN:")

puts
puts " pid = #{$$}"
puts "pgrp = #{Termios::getpgrp($stdin)}"
