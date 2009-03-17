# to input secretly [ruby-list:15968]
require 'termios'

$stdin.extend Termios

oldt = $stdin.tcgetattr
newt = oldt.dup
newt.lflag &= ~Termios::ECHO
$stdin.tcsetattr(Termios::TCSANOW, newt)
print "noecho> "
a = $stdin.gets
$stdin.tcsetattr(Termios::TCSANOW, oldt)
print "\n"
p a
