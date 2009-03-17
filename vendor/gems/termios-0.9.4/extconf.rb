require 'mkmf'

if have_header('termios.h') &&
    have_header('unistd.h')
  create_makefile('termios')
end
