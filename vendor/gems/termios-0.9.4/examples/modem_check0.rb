require 'fcntl'
require 'termios'
include Termios

DEVICE = '/dev/modem'
BAUDRATE = B115200

def dev_open(path)
  dev = open(DEVICE, File::RDWR | File::NONBLOCK)
  mode = dev.fcntl(Fcntl::F_GETFL, 0)
  dev.fcntl(Fcntl::F_SETFL, mode & ~File::NONBLOCK)
  dev
end

def dump_termios(tio, banner)
  puts banner
  puts "  ispeed = #{BAUDS[tio.ispeed]}, ospeed = #{BAUDS[tio.ospeed]}"
  ["iflag", "oflag", "cflag", "lflag"].each do |x|
    flag = tio.send(x)
    flags = []
    eval("#{x.upcase}S").each do |f, sym|
      flags << sym.to_s if flag & f != 0
    end
    puts "   #{x} = #{flags.sort.join(' | ')}"
  end
  print "      cc ="
  cc = tio.cc
  cc.each_with_index do |x, idx|
    print " #{CCINDEX[idx]}=#{x}" if CCINDEX.include?(idx)
  end
  puts
end

dev = dev_open(DEVICE)

oldtio = getattr(dev)
dump_termios(oldtio, "current tio:")

newtio = new_termios()
newtio.iflag = IGNPAR
newtio.oflag = 0
newtio.cflag = (CRTSCTS | CS8 | CREAD)
newtio.lflag = 0
newtio.cc[VTIME] = 0
newtio.cc[VMIN] = 1
newtio.ispeed = BAUDRATE
newtio.ospeed = BAUDRATE
dump_termios(newtio, "new tio:")

flush(dev, TCIOFLUSH)
setattr(dev, TCSANOW, newtio)
dump_termios(getattr(dev), "current tio:")

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

setattr(dev, TCSANOW, oldtio)
dump_termios(getattr(dev), "current tio:")
