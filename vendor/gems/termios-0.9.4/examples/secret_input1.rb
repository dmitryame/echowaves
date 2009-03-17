# to input secretly [ruby-list:15968]
require 'termios'

oldt = Termios.tcgetattr($stdin)
newt = oldt.dup
newt.lflag &= ~Termios::ECHO
Termios.tcsetattr($stdin, Termios::TCSANOW, newt)
print "noecho> "
a = $stdin.gets
Termios.tcsetattr($stdin, Termios::TCSANOW, oldt)
print "\n"
p a
