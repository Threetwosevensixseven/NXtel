IRQ Driven ESP AT command ZX Next driver
----------------------------------------

V0p8 Alpha

(c) Tim Gilberts, Infinite Imaginations, 2018

This is the fourth public release of an Interrupt driven ESP driver using
the loadable device drivers of NextZXOS.  It uses a 24K buffer in the given
memory BANK(s) or in main memory at $A000/40960 if none is specified.

Only a single command channel and a single outbound channel are supported
you cannot open extra channels they will be reported as invalid.

IPD packets may use border colour changes for diagnostics this may or may not
be kept and or able to be be disabled...  CMD channel ones do not.

Initially this supports NextZXOS BASIC streams but, we will also supply a 
semi Spectranet / sockets compatible API at some point.

The IRQ driver is used INSTEAD of the UART one previously developed to
improve buffer handling etc so that +IPD packets can be written directly
to the allocated memory buffers.  It also save a valuable driver slot.

The UART one will remain supported though, for uses other than the ESP...

It is loaded as with other IM1 drivers using:

.install /NextZXOS/espat.drv

It can also be removed with

.uninstall /NextZXOS/espat.drv

As those commands from 1.99H support loading BETA 1 or RC1 will use that 
loading method.  

(*****Until that release you MUST manually load the ESPAT.SYS into
a suitable memory page ESPINS.BAS and ESPINMM.BAS do that.  This 16K BANK uses
the top 8K as a command receive buffer.  You can either use the default
main memory of the Next or supply a 16K bank using the ASM API or from BASIC
using DRIVER.

Note that it starts in a limited fashion only gathering the status of the
UART data ready and buffer full flags.  This is so that data does not
overwrite any memory until you have formally assigned a bank or decided
to use the top 24K of main memory explicitly with a CLEAR 40959 command.

It supports an API that can be used from BASIC using a mix of DRIVER and
Streams support.  The driver can also be used from Assembler with
the NextZXOS driver API commands (see summary of M_DRVAPI at end of this
or in main NetxOS API documentation) where the Streams functions are just API
calls greater than 127...

It's ID is 'N' which is 78 decimal.  So all BASIC DRIVER commands are

DRIVER 78,n,{param1{,param2{ TO var1{,var2{,var3}}}}}

where n is the API call id / function number required.

Note if you use the pluspack AUTOEXEC then %n will be 78 if loaded so you can
say DRIVER %n,.... for clarity


Steams support
==============

The driver supports the NextZXOS BASIC streams interface as follows:

Remember you have a BASIC stream <> channel(handle) {<> ESP LinkID}

;-------
; B=$f9:  open channel
;-------

OPEN #n,"D>N"         ; simple open: HL=DE=0 Means OPEN command channel
OPEN #n,"D>N>string"  ; open with string: HL=address, DE=length
                       ; NOTE: be sure to check for zero-length strings
OPEN #n,"D>N,p1,p2"   ; open with numbers: DE=p1, HL=p2 (zeros if not prov.)
The last form will open the command channel with no numbers/0's, or p2 is a
pointer to a string of length p1 which MUST be somewhere visible below the 40K
mark or an error will result either directly or as a syntax error likely.

The safest thing to do in BASIC is to create a string variable with the connect
string and pass that to the Open - this can be done then even from BASIC in
other pages as string variables are always in workspace.  In ASM and C you can
use the ROM call MakeSPACE to do a similar thing.

For the network driver you DO NOT NEED to open a stream to the command channel
first, that can be done when you want. It can also be closed independently as
well.  Note that many commands like printing characters will empty the command
channel.  If you start reading it and get messages like CLOSED or 
WIFI DISCONNECT which you do nothing with, then the state of the system may be
unknown - it will usually recover or just give errors but, you have been warned.
There will hopefully be an DRIVER/API call (12?) to do this for you soon.

OPEN #n, "D>N"
  Opens the ESP AT command channel so that you can see the rolling
  data and query more complex data.  Prints to this channel are
  sent 'as is' so you can send other commands.
  Note that the system checks this channel and deals with some commands
  related to status - see WARNING above.
  
  This channel is'cooked' and adds an LF after CR and changes it to another
  CR on receive so that BASIC just sees an extra blank Line.
  
OPEN #n, "D>N>CTCP/UDP/SSL,address or ip,port" 
  This is effectively getaddrinfo() (was gethostbyname) + socket() + bind()
  and then connect()!
  Issues an ESP  AT+CIPSTART=x,"TCP","address",port and deals with any error
  messages to return.
  
  If a connection cannot be made you will get an "Invalid File Name" error,
  that could arise as a result of a syntax error OR the connect has failed.

***TODO - Highly likely to be used method
; OPEN #n, "D>N>LXXXX" - 
;   Creates a server listening on port XXXX
;
; OPEN #n, "D>N>A"
;   which will do the accept() for BASIC ... when a server is started then
;   the incoming next ESP Link will be used for data receipt so the ID is
;   unknown until the first connect is received - so we need
;   to track the CIPSTATUS immediately after a connect - unless we have that
;   the above call will fail, when we do then it will succeed so it can be
;   used to poll for a new connection and assign a BASIC stream to that connect
;   timing out if not received within a short period. ERROR ON will be needed
;   to deal with that as OPEN does not return a value.
;
; OPEN #n, "D>N>X"
;   If D is added then IPD debug data is returned. Along with x,CONNECT etc to
;   responses received back rather than suppressing them. i.e. DEBUG
;   any IPD packets are written to the buffer if received before you have
;   provided any other buffers - this is unlikely to happen unless you
;   send connects or listens yourself in which case the small buffer will be
;   hard to handle.
;
; OPEN #n, "D>N>D'address or ip',port"  - activate a remote debug/syslog service
;   anything printed to the channel will be sent to that address and port
;   using UDP as will internal system error messages etc.
;
; The ESP8266 has a limited number of network connections it can handle called
; LinkID's (0-4) which are set by the CIPSTART command for example.
;
; ***TODO Only 1 SSL channel is allowed so that is specifically checked.
;
; Note that closing ESP id 5 will close all channels except if in server mode so
; we do not allow that from the streams API at the moment.
;
You must have added at least a single 16K memory bank for buffers via the API
to allow an open to succeed. If you do not then all IPD data will just be in
the command stream and the buffer will exhaust quickly. 

Channel handle is returned in A - this cannot be accessed in BASIC so see
B=$fd / RETURN #n TO var 

As of Alpha 8 C is also a copy of the handle so it can be used in C (the
language) with the esx_m_drvapi call which cannot access A

If it returns with any error (carry set), "Invalid filename" will be reported
and no stream will be opened.

If there is an error Carry = 1 then A is one of (usable in ASM and C):

$81 - max channels of this type open
$82 - invalid parameter - e.g. 0 length strings
$83 - invalid connect type must be TCP, UDP or SSL
$84 - syntax error in string - missing comma?
$85 - parse error on connect address
$86 - parse error at end of connect address
$87 - error sending connect, timeout on tx probably
$88 - failed to connect to destination
$89 - connect string address is a 'far call' - must be below $9F00

;-------
; B=$fa: close channel
;-------
This call is entered with D=handle, and should close the channel
If it cannot be closed for some reason, it exits with an error (this will be
reported as "In use").

CLOSE #n

;-------
; B=$fb: output character
;-------
This call is entered with D=handle and E=character.
Returns with carry set and A<$fe, so the error
"Invalid I/O device" will be reported on a timeout for send.

Prints to the command channel are immediate but, the ESP will not USUALLY
respond until you send a CR (the LF is added by the stream).

Characters are bufferred according to the setting for that channel
This will be of 2-255 characters 1=immediate send, 0=wait for CR or 256 chars.

***TODO "End of file" will be returned if you try to print to an IPD stream with
no valid LinkID on the end of the channel handle.  This usually happens if the
xCLOSED message was missed in the command channel during transmission
processing.

PRINT #n
plus others like LIST etc.

;-------
; B=$fc: input character
;-------
This call is entered with D=handle.
Returns the character in A (with carry reset).
If no character is currently available, returns with A=$ff and carry set.
This will cause INPUT # or NEXT # to continue calling until a character
is available.
This will clear any SW buffer full flags so make sure you have checked for
data loss by reading the flags first.

Note that as of Alpha 8 it is a documented feature that the character is
also returned in E (not C like Open) for use from Z88DK

;-------
; B=$fd: get current stream pointer
;-------
This call is entered with D=handle.

This is the way you can get at the internal channel handle for the BASIC stream
and then get the assigned ESP LinkID to BASIC for use after an accept() for
example.

It also allows BASIC to get the internal handle to pass to the driver command
for a specific stream.  The handle is an index to our internal streams 1-5
from where the ESP channel # can be obtained.

The pointer is returned in DEHL (with carry reset).  I.e. HL will be
the internal channel number.

This is used with RETURN #n TO var

e.g:

RETURN #7 TO handle
DRIVER 78,7,handle TO LinkID

;-------
; B=$fe: set current stream pointer
;-------
This call is entered with D=handle and IXHL=pointer.
Exit with A=$fe and carry set if the pointer is invalid (will result in
an "end of file" error). This means you are trying to skip more
bytes than there are in the buffer or 0 bytes.
NOTE: Normally you should not use IX as an input parameter, as it cannot
      be set differently to HL if calling via the esxDOS-compatible API.
      This call is a special case that is only made by NextZXOS.
This can be used to ADD x bytes to the stream to bulk skip over incoming
data - it cannot be used to rewind the stream, error if x is > extent
This will clear any SW buffer full flags so make sure you have checked for
data loss by reading the flags first.

This is used with "GOTO #n,m" 

;-------
; B=$ff: get stream size/extent
;-------
This call is entered with D=handle
Returns the size/extent in DEHL (with carry reset).
This is the number of bytes in the input buffer at the moment.

This is used with "DIM #n TO var"



DRIVER command options
=======================

;------
; B=1: Set memory bank for CMD and SYS
;------

*** Note - this function is deprecated as from BETA1 / RC1 the initialise will
be done from .install and you will no longer be able to put it in main memory.

*** This is likely to become an Enable/Disable to allow better BASIC performance
when not using the driver.

Set available memory pages to use for SYS and CMD buffer - ignores upper values
of MSB

Converts a 16K BASIC BANK to two 8K pages - assumes they are contiguous and
available to the driver which then splits them up to page in at $A000 and $E000!

If you do not give it a bank then when it starts running it will begin to write
to main memory so make sure you have done a clear 40959 before starting it up by
calling the get or set values/flags calls.

Note that until you make this call the system will not work as this also
does initial setup.  Using 0 as param will allow it to explicity set 5 and 0
as MMU5 and MMU7 for use. Otherwise it takes a contiguous 16K bank number.

This also has the effect of starting the CMD receive by resetting
bit 7

;-----
; B=2: Set current channel for DRIVER
;-----
DE is the current channel handle you want to deal with, will default to CMD
even if that is not currently open.

;-----
; B=3: Get CMD or IPD channel values
;-----
You must have set the current channel number with API B=2 first - it is
taken from the value of DE (the first parameter) if it is 0 then the current
channel is used.  You can also set it to the internal handle (use RETURN TO) or
the fixed value 255 which is the Command channel even if it is not open.

Get values including buffer full flag and ESP internal stream number /flags in C

For IPD channel

BIT 4 = internal (buffer max marker)
BIT 5 = Embedded IPD seen - stream restarted
BIT 6 = Timeout in last period
BIT 7 = Buffer filled in last period

DE and HL are input and output positions on the ESP IPD read buffer.

These are actual memory address values in your assigned BANK
assuming it is paged at 49152.

Top two flags; the Timeout/ Buffer full flags are cleared by this call
so that each time it is used you can see if there may have been data loss.

For CMD stream0 values 

;Bit 0 = internal
;Bit 1 = 8K SW command buffer overwrite error state (temp)
;Bit 2 = UART 512Byte HW FULL error state (temp)
;Bit 3 = internal
;Bit 4 = internal (buffer max marker)
;Bit 5 = IPD packet seen flag
;Bit 6 = IPD packet mode receive disable when 1
;Bit 7 = We are disabled when 1

Note that BIT 7 is buffer full flag on other streams - stream 0 works in a 
different way.

DE and HL are input and output positions on the ESP CMD read buffer respectively

This also has the effect of starting the IPD receive by resetting bit 6

;-----
; B=4: Set CMD or IPD values
;-----
You must have set the current channel number with API B=2 first. Due to a lack
of registers in the API and the need for atomic update - this will not change.

If you are writing your own stub driver for games then you can supply the
stream in A - see espdrv.asm.

Set values of input and output buffer directly, giving 0's will reset the
buffer to empty.  You can use a relative offset (best) or the actual
address.

For CMD offset value in the 8K buffer < 8192 or the actual address E000-FFFF
For IPD offset value in the 16K buffer < 16384 or the actual address C000-FFFF

Remember Setting DE=HL with an offset or address other than 0 means empty buffer
at that point.

All session flags are cleared by this call as well.

This will affect the current 16K page buffer in use only.

;-----	
; B=5: Set CMD and IPD timeouts
;-----
Global for ESP Links and Command - does not need a channel handle.

Set RX/TX timeout - allows you to wait for variable periods for send
and receive before the system decides there is no more data or the
outbound UART is not emptying.

DE=receive (1st parameter)
HL=send (2nd parameter)

;-----
; B=6: Add 16K bank to IPD receive pool
;-----
Global - does not need a channel handle.

This allows a restricted function from Alpha 8 onwards where as long as you add
at least one more memory bank to the pool you can do a remove to get the
current receive page in whatever state it was in which

Add memory pages to available buffer pool  ignores upper values of MSB, needs a
full 16K BASIC BANK as that is the size of the IPD receive buffers.

Returns an error if the maximum 10 pages are in the pool - that is 160K
of memory by the way!

In Alpha 9 or RC1 the IRQ will autochange to the next available bank so you
could arrange for upto 160K of file (i.e. a 128K SNA) to be loaded direct
to memory in one go.

;-----
; B=7: Remove 16K BANK from channel IPD only does not apply to CMD
;-----
This is intended to allow you get get the current BANK from the current channel

Entry: DE is channel handle, default if 0

Returns: BC is the BANK number, DE and HL are the current IN and OUT

The channel will switch to the next available BANK by fetching one from the
pool. If none are available then as an IPD on the associated LinkID would
be lost the call will return an error.

;-----
; B=8: Get ESP Link ID from handle
;-----
Entry: DE is the handle

Returns: BC is the LinkID associated with that channel (if connected to the ESP)
currently associated LinkID

***TODO or -1 (65536) if there isn't one because it has disconnected.

So in BASIC it is two steps to get to the ESP LinkID 

RETURN #7 TO handle
DRIVER 78,7,handle TO LinkID

Note this will generate an API error if you try to get the LinkID for the CMD
channel as it will never have one.

;----
;B=9: Specific UART BAUD rate to be set from lookup table.
;----

Set Baud rate / prescaler DE {HL}, returns used prescaler value in BC, 
If DE is <15 then set prescaler to that - if 255 then use second value.
Actually uses it if it is not a valid one...

It supports a limited number of built in prescale values as of course
You can supply your own via DRIVER/HL command and it is mainly intended
to support the ESP8266 Network interface which only needs a few speeds.

	DEFW 243,248,256,260,269,278,286,234 ; Was 0 - 115200 adjust for 0-7
	DEFW 486,496,512,521,538,556,573,469 ; 1 - 56k
	DEFW 729,744,767,781,807,833,859,703 ; 2 - 38k
	DEFW 896,914,943,960,992,1024,1056,864 ; 3 - 31250 (MIDI)
	DEFW 1458,1488,1535,1563,1615,1667,1719,1406 ; 4 - 19200
	DEFW 2917,2976,3069,3125,3229,3333,3438,2813 ; 5 - 9600
	DEFW 5833,5952,6138,6250,6458,6667,6875,5625 ; 6 - 4800
	DEFW 11667,11905,12277,12500,12917,13333,13750,7 - 11250 ; 2400
	DEFW 122,124,128,130,135,139,143,117 ; 230400 -8	
	DEFW 61,62,64,65,67,69,72,59 ;460800 -9
	DEFW 49,50,51,52,54,56,57,47 ;576000 -10
	DEFW 30,31,32,33,34,35,36,29 ;921600 -11
	DEFW 24,25,26,26,27,28,29,23 ;1152000 -12
	DEFW 19,19,20,20,21,21,22,18 ;1500000 -13
	DEFW 14,14,15,15,16,16,17,14 ;2000000 -14
	
If DE=255 then use second value in HL directly as the prescaler.
Note that your own prescaler MUST correct for the video timing
as in the above table which represents VGA0-6 and HDMI7

WARNING: Setting unusual UART rates on the ESP will make it hard to find it
again if you forget what speed - use UART_CUR if you MUST fiddle - at least
a power off will put it back to default usually 0/115200

;----
;B=10: Set output buffer mode for channel
;----
Entry:	DE is channel, 0 for default - IPD only will not work on CMD channel.
      	HL is mode 2-255 characters 1=immediate send, 0=wait for CR or 256 chars. 

Channel defaults to mode 1 when opened.

;-----
;B=11: enable/disable embedded IPD detect
Entry: DE is channel, 0 for default - IPD only will not work on CMD channel.
       HL is mode 0x08 disable (default), 0x00 enable

Channel defaults to mode 8 when opened.

***TODO 
-------

a)

;----
;B=xx: Process and Empty CMD Buffer
;----
This will go through the command buffer and deal with any system messages - this
is useful if you plan to use the command channel for comms with the ESP
at the moment it would just wipe it... so use B=4 0,0...

b)

Find optimum UART prescaler that matches ESP one actually set for
increased reliability...

c)

Use the DRIVER command to pass in / get packets of data rather than single
bytes / buffering - especially useful for UDP datagrams to a stream.
so like sendto() and recvfrom()
This will likely be provided as a 256/512 byte block in the BASIC workspace.

d)

It will also support getting a 16K BANK back as a whole buffer from a channel.
The channel system allows swapping between two sets of 16K for double buffering.
This will make block work faster for large receives


Using from Assembler
====================

On entry in assembler, use B=call id with HL,DE other parameters.
(NOTE: HL will contain the value that was either provided in HL (when called
from dot commands) or IX (when called from a standard program).

;Use IDE_DRIVER ($01CF) to open ESP or via NextZXOS M_DRVAPI ($92)
;Error return if it is not loaded or present.

		LD	C,'N'	;We want to open the ESPAT driver for use
		LD	B,$f9	;Open the channel
		LD	DE,0	;No params
;		LD	HL,0	;If in a DOT command
		LD	IX,0	;At the moment we are not a DOT command so no HL	
		RST	8
		DEFB	$92	;m_DRVAPI
		JR	C,Init_Error
		LD	(ESPAT_cmd_handle),A

When called from the DRIVER command, DE is the first input and HL is the 
second.

When returning values, the DRIVER command will place the contents of BC into
the first return variable, then DE and then HL.  Just use them directly in
assembler...

Changed in A6 : Codes from 64-127 WERE used by built in functions to control IRQ
etc for stream 0 which was the ESP Command channel.

Codes from 1-126 are used by ESPAT.SYS to provide functions for all the
main data streams CMD and IPD.

Remember that >127 are the Streams API calls $F9 = 249... which is Open.

The UART will begin to lose data if it misses more than one interrupt
at 115K baud on the UART/ESP interface. So be very careful with DI/EI and
any SD card access...  Some BASIC commands may have an effect as well so best
to run at 14MHz probably!  Internally the code polls when waiting so that
data is not lost during stream and driver operation as that runs DI.

Timeouts in IPD data streams can be seen as Tilde ~ characters of the quantity
we were expecting - they are just lost on the Command stream as we have no idea
how many we lost.



NextZXOS API's
==============

As a reminder here is the NextZXOS API documentation for M_DRVAPI - please check
that for most up to date version as it could have changed since this
was written.  It is of course best to use the full NextZXOS API...
	
; *************************************************************************
; * M_DRVAPI                                                                *
; *************************************************************************
; Entry:
;       C=driver id (0=driver API)
;       B=call id (or as described by driver documentation)
;       HL,DE=other parameters
; Exit (success):
;       Fc=0
;       other values depend on API call
; Exit (failure):
;       Fc=1
;       A=0, driver not found
;       else A=driver-specific error code (esxDOS error code for driver API)

; If C=0, the driver API is selected and calls are as follows:
;
; B=0, query the RTC
; (returns the same results as M_GETDATE)
;
; B=1, install a driver
;       D=number of relocations (0-255)
;       E=driver id, with bit 7=1 if should be called on an IM1 interrupt
;       HL=address of 512-byte driver code followed by D x 2-byte reloc offsets
; Possible error values are:
;       esx_eexist (18)         driver with same id already installed
;       esx_einuse (23)         no free driver slots available
;       esx_eloadingko (26)     bad relocation table
;
; B=2, uninstall a driver
;       E=driver id (bit 7 ignored)
;
; B=3, get paging value for driver banks
;       C=port (always $e3 on ZXNext)
;       A=paging value for DivMMC bank containing drivers (usually $82)
;
;IX when called from outside a dot command, HL is for internal use (and dot commands)



Using the driver as an API in Games
===================================

If you do not wish to use the NextZXOS driver infrastructure then the source
for the relocatable IRQ stub / API launcher is supplied as espdrv.asm and
espdrv_drv.asm - instructions are in the file to assemble with PASMO.

You can modify this to allow you to use the ESPAT.SYS driver services directly
you just need to provide a regular IRQ call to the service routine and make
sure you have supplied at least one 16K bank to the system for buffers. 

You can if you want use the jump table to call the functions directly just
remember to have top of stack = HL before (and the MMU paged in of course)


Notes:
======

a) Why not 8K buffers?

A 16K BANK buffer is used as that can cope with 3 full size IPD packets per
used stream. According to this post:

https://bbs.espressif.com/viewtopic.php?t=1575

Max IPD packet size can be 4x1460 = 5840 bytes!!!!


b) SSL connect does not yet work...

On the SSL question as at Feb 2017

https://bbs.espressif.com/viewtopic.php?f=16&t=3381

Our AT Framework can be used in HTTP, not HTTPs. If using HTTP, you should add some code in your project, and you can refer to the demo code as below:
https://github.com/espressif/esp8266-nonos-sample-code/tree/master/04Protocal/IoT_Demo_https


3) Teletext?

See NxTel as it is Awesome....

http://teastop.plus.com:8080/

4) BASIC

Installer for the moment

.install /nextzxos/espat.drv
PRINT "Installed ESPAT.DRV"
BANK NEW %m: PRINT "ESPAT.SYS Load page ";%m
LOAD "/nextzxos/espat.sys" BANK %m,0,exactlength (will fix file at 8192 for simples)
DRIVER 78,1,%m:REM ensures DRV knows where SYS is and patches/initialises
BANK NEW %b: PRINT "Allocating 1 buffer ";%b
DRIVER 78,6,%b
DRIVER 78,9,0 TO %p : PRINT "115K Baud - precaler ";%p
DRIVER 78,3 : PRINT "IPD Driver started"

This is in the autoexec-pluspack.bas - if you hold ENTER while booting it will
not autoload so you can pick individual drivers or just then use space to boot
with none.  There are some REM's in front of lines to auto load what you want 
just resave as AUTOEXEC.BAS LINE 10 when it is set how you want.

Other things
------------

It would be nice to get as far as this project has done with Spectranet and the
plato service as well.

https://github.com/tschak909/platotermzx

https://www.irata.online/

%mount 0,"irata.online"
%load ""

This can also connect to cyberserv! "cyber1.org"
bigjump is a menu of the popular games and files...

This is basically a very powerful 8080 based terminal that can access an old
mainframe hosted system.  Useful documents here:

http://www.control-data.info/CybisRelease.html

Change Log
==========

;Alpha 8 2 September 2018
-------------------------

Several corrections to API docs like BC as return and clarify copies of
A register returns in BC/DE etc for use from C in Z88DK

Fixed up Open to prevent more than one IPD channel, some API fuctions like "get
handle" implemented in a limited fashion.

Re-enabled embedded IPD handling - causes crash on malformed number BUG!!!! TODO
so added enable / disable option.

OPEN from ASM / C returns useful errors in A - BASIC only has two options.

Implemented simple BANK switching to allow better handling of 16K data lumps.

Border debugging now resets to system border setting not just BLACK.

- TODO for BETA 1 / RC1

Modify TERMINAL.BAS/BIN to use this driver... and provide ANSI - actually will
be new C application based on Z88DK classic library.

Change to new .install for loading SYS


;Alpha 7 18 August 2018
-----------------------

Corrections to API - to allow DE as channel handle in most cases
except SET (this has to be done in one go to be Atomic) BASIC default=0
so that will use Current Channel as expected.

Changed OUTDEMO to catch timeouts on sending the string and recover not bomb out

Timeouts are rarer now as they only seem to happen if you overload the ESP with
a large amount of small packets and/or there are delays on sending the data
over the WIFI network due to bad signals.  Try increasing the outgoing buffer
length.  Again BASIC should wrap any sends in an ON ERROR although commands like
LIST# can only fail to finish but, at least the program overall can recover.

Added buffered output and mode setting option for imediate send, 2-256 chars or
send on LF or 256 chars.

Created ESPTERMxx.BAS as a simple terminal demo on how to use the system. This
will probably replace IN and OUT demo at BETA 1

Provided installers as small BASIC stubs and modified INDEMO to assume it is
loaded like ESPDEMO which will has been renamed to OUTDEMO

Fixed paging issue to run fully paged out.

OPEN IPD now supports the actual string provided with some error checking so
needs to be trapped with ON ERROR if you want to provide a nice user
experience.

;Alpha 6 1 August 2018
------------------------

API totally rewritten as DRV reduced to bare stub to allow integration with
ZEUS and other remote debuggers / non NextZXOS users of the code providing an
API for games as per Stretch Goal.

ESPAT.SYS fixed at 8K for easy BASIC memory loading

- Known BUGS:

Only works in main memory not paged at the moment - introduced in Alpha 5

Send still tripping due to busy... (probably buffer clear issue)

Released only as an API document - warning use Alpha5ReadMe for working
system.

;Alpha 5 30 July 2018
----------------------

Bug from refactoring code to .SYS on buffer size corrected - this caused "end
of file" errors on INDEMO104.BAS so it bombed out occasionally.

The timeouts seen by Robin on send using ESPDEMO16.BAS can be reduced by
increasing the timeout value with a DRIVER 78,4,1024 (78,5 on ALpha6+) but, it's
slower sending a character. In ASM you just need to retry on error - BASIC will
bomb and the ON ERROR will exit the program - you could change this to PAUSE
and then retry probably. This is a bug in the way the ESP is driven I think.
The number of "busy..." messages skipped has doubled but, it still seems to
happen.  However the code is rock stable for receiving data and you can send
some small messages on the data channel so it works enough for experimenting.

;Alpha 4 29 July 2018
------------------------

You can now open and close streams (including command channel) in any order
so once OPEN string is working you will not need command channel in normal use.

B=66 removed from Command API

Line in above example loader missing DRIVER 78,67,%m (even if in RAM need %m=0)
as this also triggers the initialise code!!!

Bugs in AUTOEXEC.BAS fixed like last item...

Refactored all possible DRV code into SYS as as had run out of room for diags.

Shortened and optimised send path / CMD buffer stream for speed

CMD channel now cooked - on input an LF will become a CR so appears as extra
line.  On output an LF is added.

Send is working for IPD channel but hellish slow - need to add buffering and
provide some form of flag control to turn that on and off, set buffer size etc
Meanwhile think of it as working with a Retro experience 1200/300 baud modem :)

I have included a copy of the BASIC test harness I use that loads the driver
so you do not have to have the AUTOEXEC.BAS setup. So you have:
INDEMOxxx.BAS which is the test harness I use - you can type AT commands and
see incoming packets - it auto connects to 192.168.0.2:10000 but that is a line
you can change.  I run nc -l 10000 on the PC to provide a test connection.
"autoexec-pluspack.bas" which is the loader with temp code pending .install 
being able to allocate pages - at which point DIVMMC memory will be used for SYS
ESPDEMOxxx.BAS uses the autoexec loaded driver to be similar to the harness
but the sent data goes to the IPD channel not the command channel.

Main memory API test call now prints correct Version number

;Alpha 3 27 July 2018
------------------------

First public showing - send on opened IPD channel broken, receive only.

;Alpha 2 and Alpha 1
------------------------

Internal non working code scavenged from .UART, UART.DRV, TERMINAL.BIN etc

