IRQ Driven ESP AT command ZX Next driver
----------------------------------------

V0p1 Alpha

(c) Tim Gilberts, Infinite Imaginations, 2018

This is the initial release of an Interrupt driven UART/ESP driver using the
loadable device drivers of NextOS.  It uses an 24K buffer in the given
memory BANK(s) or in main memory at $A000/40960 if none is specified.

Initially this supports NextOS BASIC streams but, we will also supply a 
semi Spectranet / sockets compatible API at some point.

The IRQ driver is used INSTEAD of the UART one previously developed to
improve buffer handling etc so that +IPD packets can be written directly
to the allocated memory buffers.

It is loaded as with other IM1 drivers using:

.install /nextos/espat.drv

It can also be removed with

.uninstall /nextos/espat.drv

Until those commands support loading additional pages you MUST manually load
the ESPAT.SYS into a suitable memory page.  This 16K BANK uses the top 8K as a
command receive buffer.  You can either use the default main memory of the
Next or supply a 16K bank using the ASM API or from BASIC using DRIVER.

Note that it starts in a limited fashion only gathering the status of the
UART data ready and buffer full flags.  This is so that data does not
overwrite any memory until you have formally assigned a bank or decided
to use the top 24K of main memory explicitly with a CLEAR 40959 command.

It supports an API that can be used from BASIC using a mix of DRIVER and
Streams support.  The driver can also be used from Assembler with
the NextOS driver API commands (see summary of M_DRVAPI at end of this
or in main NetxOS API documentation) where the Streams functions are just API
calls greater than 127...

It's ID is 'N' which is 78 decimal.  So all BASIC DRIVER commands are

DRIVER 78,n,{param1{,param2{ TO var1{,var2{,var3}}}}}

where n is the API call id / function number required.

On entry in assembler, use B=call id with HL,DE other parameters.
(NOTE: HL will contain the value that was either provided in HL (when called
from dot commands) or IX (when called from a standard program).

;Use IDE_DRIVER ($01CF) to open ESP or via NextOS M_DRVAPI ($92)
;Error return if it is not loaded or present.

		LD	C,'N'	;We want to open the ESPAT driver for use
		LD	B,$f9	;Open the channel
		LD	DE,0	;No params
		LD	HL,0	
		RST	8
		DEFB	$92	;m_DRVAPI
		JR	C,Init_Error
		LD	(ESPAT_cmd_handle),A

When called from the DRIVER command, DE is the first input and HL is the 
second.

When returning values, the DRIVER command will place the contents of BC into
the first return variable, then DE and then HL.  Just use them directly in
assembler...

Codes from 64-127 are used by built in functions to control IRQ etc for stream 0
which is the ESP Command channel.

Codes from 1-126 are used by ESPAT.SYS to provide extended functions for the
main data streams 

Remember that >127 are the Streams API calls $F9 = 249... which is Open.

The UART will begin to lose data if it misses more than one interrupt
at 115K baud on the UART/ESP interface. So be very careful with DI/EI and
any SD card access...  Some BASIC commands may have an effect as well so best
to run at 14MHz probably!


;------
; B=64: Get CMD stream0 values
;------
Get CMD buffer values including flags C=Flag status

;Bit 0 = internal
;Bit 1 = 8K SW command buffer overwrite error state
;Bit 2 = UART 512Byte HW FULL error state
;Bit 3 = internal
;Bit 4 = internal
;Bit 5 = IPD packet mode receive enable when 1
;Bit 6 = IPD packet seen flag
;Bit 7 = We are disabled

Note that BIT 7 is buffer full flag on other streams - stream 0 works in a 
different way.

DE and HL are input and output positions on the ESP CMD read buffer respectively

;------
; B=65: Set CMD stream0 values
;------
Set values of input and output buffer directly 

This will also clear some flags and start TSR execution.

When disabling it is possible the DE and HL values may not fully reset
as the IRQ could change them.  They should then be set when enabling.

*** This is for advanced use really

;-----	
;B=66: Set RX/TX timeout
;-----

Allows you to wait for variable periods for send and receive before the system
decides there is no more data or the outbound UART is not emptying.

DE = Receive timeout and HL is Send timeout

;------
; B=67: Set memory bank for CMD and SYS
;------
Set available memory pages to use for SYS and CMD buffer - ignores upper values
of MSB

Converts a 16K BASIC BANK to two 8K pages - assumes they are contiguous and
available to the driver which then splits them up to page in at $A000 and $E000!

If you do not give it a bank then when it starts running it will begin to write
to main memory so make sure you have done a clear 40959 before starting it up by
calling the get or set values/flags calls.


***TODO

There is unlikely to be many more IRQ system DRIVER commands added...


;----
;B=1: Specific UART BAUD rate to be set from lookup table.
;----

Set Baud rate / prescaler DE {HL}, returns used prescaler value in BC, 
If DE is <15 then set prescaler to that - if 255 then use second value.
Actually uses it if it is not a valid one...

It supports a limited number of built in prescale values as of course
You can supply your own via DRIVER/HL command and it is mainly intended
to support the ESP8266 Network interface which only needs a few speeds.

	DEFW 243,248,256,260,269,278,286,234 ; Was 0 - 115200 adjust for 0-7
	DEFW 486,496,512,521,538,556,573,469 ; 56k
	DEFW 729,744,767,781,807,833,859,703 ; 38k
	DEFW 896,914,943,960,992,1024,1056,864 ; 31250 (MIDI)
	DEFW 1458,1488,1535,1563,1615,1667,1719,1406 ; 19200
	DEFW 2917,2976,3069,3125,3229,3333,3438,2813 ; 9600
	DEFW 5833,5952,6138,6250,6458,6667,6875,5625 ; 4800
	DEFW 11667,11905,12277,12500,12917,13333,13750,11250 ; 2400
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

;-----
; B=2: Get IPD values
;-----
Get values including buffer full flag and ESP internal stream number in C
DE and HL are input and output positions on the ESP IPD read buffer.

These are actual memory address values in your assigned BANK
assuming it is paged at 49152.

Buffer full flag is cleared by this call - so that each time it is used
you can see if there may have been data loss.

;-----
; B=3: Set IPD values
;-----
Set values of input and output buffer directly (also resets the flags)

***TODO document functionality...

;-----	
; B=4: Set IPD timeouts
;-----
Set RX/TX timeout - allows you to wait for variable periods for send
and receive before the system decides there is no more data or the
outbound UART is not emptying.

This exists but, will likely not be needed as it is for the 66 call to set
the values in ESPAT.SYS.  DO NOT USE.

;-----
; B=5: Add 16K bank to IPD receive pool
;-----
add memory pages to available buffer pool 
ignores upper values of MSB, needs a full 16K BASIC BANK as that is the size
of the IPD receive buffers.

***Alpha - only one BANK can be added to the pool at the moment as only one
stream is available and double banking is not implemented in the API 




***TODO
=======

Use the DRIVER command to pass in / get packets of data rather than single
bytes - especially useful for UDP datagrams to a stream.
so like sendto() and recvfrom()
This will likely be provided as a 256/512 byte block in the BASIC workspace.


It will also support getting a 16K BANK back as a whole buffer.  The stream
system allows swapping between two sets of 16K for double buffering.  This
will make block work faster for large receives




Steams support
==============

The driver supports the streams interface as follows:

;-------
; B=$f9:  open channel
;-------

OPEN #n,"D>X"         ; simple open: HL=DE=0
OPEN #n,"D>X>string"  ; open with string: HL=address, DE=length
                       ; NOTE: be sure to check for zero-length strings
OPEN #n,"D>X,p1,p2"   ; open with numbers: DE=p1, HL=p2 (zeros if not prov.)

For the network driver you MUST open the command channel first
in fact any data in the string after the first open is ignored and you get
back the command channel handle.

OPEN #n, "D>N"
  opens the ESP AT command channel so that you can see the rolling
  data and query more complex data.  Prints to this channel are
  sent 'as is' so you can send other commands.
  Note that the system checks this channel and deals with some commands
  related to status
  unlike other channels it will not block - you may receive a timout
  return, this allows INPUT to be used to get responses but, not hang
  and still find the end of a sequence etc. This will be char 0 or null string

OPEN #n, "D>N>CTCP/UDP/SSL,address or ip,port" 
  This is effectively getaddrinfo() (was gethostbyname) + socket() + bind()
  and then connect()!
  Issues an ESP  AT+CIPSTART=x,"TCP","address",port and deals with any error
  messages to return.

***TODO - Highly likely to be used method
; OPEN #n, "D>N>LXXXX" - 
;   Creates a server listening on port XXXX

;  (Might be better as DRIVER 78,y,XXXX as the stream number will be unknown
;  less use although it could be used for CLOSE with reads triggering the
;  search in the command channel for the value,CONNECT to go in the OPEN?)
   
; OPEN #n, "D>N>A"
;   which will do the accept() for BASIC ... when a server is started then
;   the incoming next ESP channel will be used for data receipt so the ID is
;   unknown until the first connect is received - so we need
;   to track the CIPSTATUS immediately after a connect - unless we have that
;   the above call will fail, when we do then it will succeed so it can be
;   used to poll for a new connection and assign a BASIC stream to that connect
;
; OPEN #n, "D>N>D"
;   If D is added then IPD debug data is returned. Along with x,CONNECT etc to
;   responses received back rather than suppressing them. i.e. DEBUG
;   any IPD packets are written to the buffer if received before you have
;   provided any other buffers - this is unlikely to happen unless you
;   send connects or listens yourself in which case the small buffer will be
;   hard to handle.
;
; OPEN #n, "D>N>S'address or ip',port"  - activate a remote debug/syslog service
;   anything printed to the channel will be sent to that address and port
;   using UDP.
;
; The ESP8266 has a limited number of network channels it can handle 0-4 which
; are set by the CIPSTART command for example.
;
; ***TODO Only 1 SSL channel is allowed so that is specifically checked.
;
; Note that closing ESP id 5 will close all channels except if in server mode so
; we do not allow that from the streams API at the moment.
;
; You must have added at least a single 16K memory bank for buffers via the API
; to allow an open to succeed. If you do not then all IPD data will just be in
; the command stream and the buffer will exhaust quickly. 

Channel handle is returned in A - this cannot be accessed in BASIC so see
B=$fd / RETURN #n TO var 

If it returns with any error (carry set), "Invalid filename" will be reported
and no stream will be opened.
 
;-------
; B=$fa: close channel
;-------
This call is entered with D=handle, and should close the channel
If it cannot be closed for some reason, it exits with an error (this will be
reported as "In use").
This will happen if you try to close CMD channel with others open...

CLOSE #n

;-------
; B=$fb: output character
;-------
This call is entered with D=handle and E=character.
Returns with carry set and A<$fe, so the error
"Invalid I/O device" will be reported on a timeout for send.

; **TODO we should add a small output buffer to prevent any blocking then
; use the End of file error return if it is filled before transmission.
; This will have to be added to the IRQ routine for transmission but space
; is limited at the moment unless we switch to a TSR and memory block solution

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

;-------
; B=$fd: get current stream pointer
;-------
This call is entered with D=handle.

;***TODO this is likely the way we will return the assigned ESP stream to
; BASIC for use afer an accept()
We will use this to allow BASIC to get the internal handle to pass
to the driver command for a specific stream.  The handle is an index to
our internal streams 0-5 from where the ESP channel # can be obtained.

You should return the pointer in DEHL (with carry reset).  I.e. HL will be
the internal ESP channel number.

This is used with RETURN #n TO var

;-------
; B=$fe: set current stream pointer
;-------
This call is entered with D=handle and IXHL=pointer.
Exit with A=$fe and carry set if the pointer is invalid (will result in
an "end of file" error). This means you are trying to skip more
bytes than there are in the buffer.
NOTE: Normally you should not use IX as an input parameter, as it cannot
      be set differently to HL if calling via the esxDOS-compatible API.
      This call is a special case that is only made by NextOS.
This can be used to ADD x bytes to the stream to bulk skip over incoming
data - it cannot be used to rewind the stream, error if x is > extent

This is used with "GOTO #n,m" 

;-------
; B=$ff: get stream size/extent
;-------
This call is entered with D=handle
Returns the size/extent in DEHL (with carry reset).
This is the number of bytes in the input buffer at the moment.

This is used with "DIM #n TO var"




NextOS API's
============

As a reminder here is the NextOS API documentation for M_DRVAPI - please check
that for most up to date version as it could have changed since this
was written.  It is of course best to use the full NextOS API...

	
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

http://teastop.plus.com:8080/


