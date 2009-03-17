=begin

= ruby-termios

Ruby-termios enables you to use termios(3) interface.


== Termios module

Termios module are simple wrapper for termios(3).  It can be included
into IO-family classes and can extend IO-family objects.  In addition,
the methods can use as module function.

=== Module Functions

--- Termios.tcdrain(io)
--- Termios.drain(io)
    It calls tcdrain(3) for ((|io|)).

--- Termios.tcflow(io, action)
--- Termios.flow(io, action)
    It calls tcflow(3) for ((|io|)).

--- Termios.tcflush(io, queue_selector)
--- Termios.flush(io, queue_selector)
    It calls tcflush(3) for ((|io|)).

--- Termios.tcgetattr(io)
--- Termios.getattr(io)
    It calls tcgetattr(3) for ((|io|)).

--- Termios.tcgetpgrp(io)
--- Termios.getpgrp(io)
    It calls tcgetpgrp(3) for ((|io|)).

--- Termios.tcsendbreak(io, duration)
--- Termios.sendbreak(io, duration)
    It calls tcsendbreak(3) for ((|io|)).

--- Termios.tcsetattr(io, flag, termios)
--- Termios.setattr(io, flag, termios)
    It calls tcsetattr(3) for ((|io|)).

--- Termios.tcsetpgrp(io, pgrpid)
--- Termios.setpgrp(io, pgrpid)
    It calls tcsetpgrp(3) for ((|io|)).

--- Termios.new_termios
    It is alias of ((<Termios::Termios.new>)).

=== Methods

The methods can use for objects which include Termios module or are
extended by Termios module.

--- tcdrain
    It calls tcdrain(3) for ((|self|)).

--- tcflow
    It calls tcflow(3) for ((|self|)).

--- tcflush(queue_selector)
    It calls tcflush(3) for ((|self|)).

--- tcgetattr
    It calls tcgetattr(3) for ((|self|)).

--- tcgetpgrp
    It calls tcgetpgrp(3) for ((|self|)).

--- tcsendbreak(duratiofn)
    It calls tcsendbreak(3) for ((|self|)).

--- tcsetattr(flag, termios)
    It calls tcsetattr(3) for ((|self|)).

--- tcsetpgrp(pgrpid)
    It calls tcsetpgrp(3) for ((|self|)).

=== Constants

Many constants which are derived from "termios.h" are defined on Termios
module.

IFLAGS, OFLAGS, CFLAGS and LFLAGS are Hash object.  They contains Symbols of
constants for c_iflag, c_oflag, c_cflag and c_lflag.

CCINDEX and BAUDS are Hash object too.  They contains Symbols of constats for
c_cc or ispeed and ospeed.

== Termios::Termios class

A wrapper class for "struct termios" in C.

=== Class Methods

--- Termios::Termios.new
    It creates a new Termios::Termios object.

=== Instance Methods

--- iflag
--- c_iflag
    It returns value of c_iflag.

--- iflag=(flag)
--- c_iflag=(flag)
    It sets flag to c_iflag.

--- oflag
--- c_oflag
    It returns value of c_oflag.

--- oflag=(flag)
--- c_oflag=(flag)
    It sets flag to c_oflag.

--- cflag
--- c_cflag
    It returns value of c_cflag.

--- cflag=(flag)
--- c_cflag=(flag)
    It sets flag to c_cflag.

--- lflag
--- c_lflag
    It returns value of c_lflag.

--- lflag=(flag)
--- c_lflag=(flag)
    It sets flag to c_lflag.

--- cc
--- c_cc
    It returns values of c_cc.

--- cc=(cc_ary)
--- c_cc=(cc_ary)
    It sets cc_ary to c_cc.

--- ispeed
--- c_ispeed
    It returns c_ispeeed.

--- ispeed=(speed)
--- c_ispeed=(speed)
    It sets speed to c_ispeed.

--- ospeed
--- c_ospeed
    It returns c_ospeeed.

--- ospeed=(speed)
--- c_ospeed=(speed)
    It sets speed to c_ospeed.

=end
