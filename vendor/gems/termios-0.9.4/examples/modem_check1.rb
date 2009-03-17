require 'fcntl'
require 'termios'

DEVICE = '/dev/modem'
BAUDRATE = Termios::B115200

def dev_open(path)
  dev = open(DEVICE, File::RDWR | File::NONBLOCK)
  mode = dev.fcntl(Fcntl::F_GETFL, 0)
  dev.fcntl(Fcntl::F_SETFL, mode & ~File::NONBLOCK)
  dev
end

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

dev = dev_open(DEVICE)

oldtio = Termios::tcgetattr(dev)
dump_termios(oldtio, "current tio:")

newtio = Termios::new_termios()
newtio.iflag = Termios::IGNPAR
newtio.oflag = 0
newtio.cflag = (Termios::CRTSCTS | Termios::CS8 | Termios::CREAD)
newtio.lflag = 0
newtio.cc[Termios::VTIME] = 0
newtio.cc[Termios::VMIN] = 1
newtio.ispeed = BAUDRATE
newtio.ospeed = BAUDRATE
dump_termios(newtio, "new tio:")

Termios::tcflush(dev, Termios::TCIOFLUSH)
Termios::tcsetattr(dev, Termios::TCSANOW, newtio)
dump_termios(Termios::tcgetattr(dev), "current tio:")

"AT\x0d".each_byte {|c|
  c = c.chr
  p [:write_char, c]
  dev.putc c
  d = dev.getc
  p [:echo_back, d && d.chr || nil]
}

r = ''
while /OK\x0d\x0a/o !~ r
  r << dev.getc.chr
  p [:response, r]
end

Termios::tcsetattr(dev, Termios::TCSANOW, oldtio)
dump_termios(Termios::tcgetattr(dev), "current tio:")
