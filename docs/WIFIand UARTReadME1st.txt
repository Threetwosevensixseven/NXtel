The ZX Next - The UART and Beyond.
----------------------------------

AKA The Internet Toolbox

Verson 3.0 / UART.DRV / ESPAT.DRV Alpha 7

The background to this feature of the ZX Next can be found on the system
website:

https://www.specnext.com/the-next-on-the-network/ - with a video!

The ESP8266 WiFi module used in that demo is supplied in the Plus versions of
the Next and can be added as an easy upgrade for others as a socket is provided.

That socket (or if the J15 header on the right of the board is added) gives
access to the onboard UART (universal asynchronous receiver-transmitter) of
the Next.  You can use this without a WiFi module for serial connections as
as well - see later.

So that is the hardware now to the software.  The PlusPack adds support for
this facility in three ways:

1/ .UART is a simple DOT command that works in NextZXOS (and ESXDOS) to allow
you to talk to a connected device which could be WiFi module.  Due to the
limitations of the 512byte hardware buffer it can only be used for small amounts
of data and is mainly intended to allow diagnosis.  It does include a simple
CIPSEND mode that allows connections to be made with an ESP WiFi module.

2/ UART.DRV is an interrupt driven driver (NextZXOS only) which can provide a
16K software buffer which means much less incoming data is lost.  There is both
a simple demo IUDEMO and a terminal program (not a DOT command) that provides an
alternative to .UART that can handle much more data.  This is intended for users
of the port without the WiFi module really but can be used to setup the ESP.

The TERMINAL provided is much better than .UART and you will have better results
following through some of the examples below but, note that some key controls
have changed like EDIT which now changes the Edit mode and GRAPHICS the BAUD
rate - as it uses the standard ROM keyboard driver the full PS2 is now supported
and of course any replacement IRQ keyboard driver will work.

3/ You can also begin to play with the real feature of the Internet Toolbox
which is the ESPAT driver for BASIC (again NextZXOS only) - Alpha7 is included
in this version with the new API.  It can be used with the BASIC ESPTERM 
program to chat over an IP link and the ESPHTTP sample program shows how a web
page can be retrieved from BASIC but, not rendered at the moment...

The Source code to the IRQ stub is provided to allow the ESPAT code to be used
in games that take over the machine provding the stretch goal of a gaming API.

Be sure to check out NXTel the Viewdata (Prestel/Teletext) terminal that if it
isn't already, will pretty soon be using ESPAT to allow the Next to connect and
get news pages from the Viewdata servers already online... 

What is the .UART command in BIN?
---------------------------------

The .UART command in the distribution is a development of the one from Victor's
video that provides more facilities to use the serial connection port either
directly through some form of serial converter e.g. a USB to TTL serial or
standard RS232 module (probably based on the MAX232) and of course to an ESP-01
WiFi module plugged in to the header. This will work from NextOS and from ESXDOS
at the moment.

The current controls are mapped to Spectrum keys:

EDIT		SHIFT+1 - Cycle output mode in V3 or BAUD RATE in V2
CAPS LOCK	SHIFT+2 - On/off toggle (on by default)
TRUE VIDEO	SHIFT+3 - Debug mode for CIPSEND on/off (silent)
INV VIDEO	SHIFT+4 - CIPSEND mode on/off also does an ATE0
GRAPHICS	SHIFT+9 - Change BAUD rate in V3
DELETE		SHIFT+0 - (PS2 KB one doesn't work in V2 use SHIFT + 0)
Exit Program	Symbol Shift and Space together.
  
It handles the UART protocol as per the website above:

The ports are 0x143b = 5179 for RX and 0x133b = 4923 for TX.
A read on the TX port shows the status of the FIFO buffer and the TX line
bit 0: returns ‘0’ if the FIFO buffer is empty or
       ‘1’ if there is data to be collected.
bit 1: returns the TX status: ‘1’ when the TX is still transmitting last byte or
       ‘0’ when the TX is idle.
bit 2: returns the FIFO buffer status: ‘1’ if the buffer is full, or 
       ‘0’ when the buffer has space to hold another incoming byte.

This is fine to use the serial interface as an ASCII terminal or the AT commands
of the ESP in single connection mode.  To do proper networking with the ESP you
will need a full suite of interrupt driven drivers - which I'm sure are being
brewed in a lab at the moment.


Using the UART without a WiFi module
------------------------------------

A USB serial connection allows you to do all sorts of clever things - it is
possible to connect up to a PC like this for transferring data.  In fact if you
were an early purchaser you probably bought one with your ESP-01 as it is the
one needed to program it. 

If you use one of the easy to get TTL modules then you can communicate with PC's
and other older machines - E.g. a real Spectrum with Interface 1... KevB is
using one for his PC - see article on the forum at:

https://www.specnext.com/forum/viewtopic.php?f=6&t=895  

It should be possible just to hook up to an external Raspberry PI for example
and use a serial console connection allowing you to use the ZX Next as the
keyboard... as the voltages match it should be fine just to connect the UART
RX/TX and GND to the PI's PIN's 4/5/6 GND/TXD0-GPIO14/RXD0-GPIO15 See

https://elinux.org/RPi_Serial_Connection

There is a diagram of the GPIO header on:

https://elinux.org/RPi_Low-level_peripherals

Be aware of the differences with a PI3.


I just want to use my WiFi module
---------------------------------

So if you are not an adventurous hardware hacker and have plugged in an ESP01
WiFi module or have a machine with one prefitted then lets look at using that...

Having watched the Video, to save you pausing all the time here is how to make
it do something with a few early steps.

So either type .UART (V22c) at the prompt or better LOAD "TERMINAL.BAS" (V3)
and RUN it.

First of all when you press ENTER you should get 'ERROR' because you didn't send
a valid command to the ESP module...

If you don't then it may be a number of things:

You are using the TBU and firmware BEFORE 0.8 and NextOS 1.92 - if so this will
only work at 3.5Mhz so slow the machine down and restart .UART!

You are using a TBU and firmware with a Core .29 or greater, with an OLD copy
of the UART program which wrote the BAUD rate differently - if so when you cycle
through the speeds EDIT (SHIFT+1) you will find it may 'work' at 38400 - it is
actually a fluke as the old value for that rate is quite close to the value
needed for 115200 on the new system.

Your module may have come with a default baud rate other than the 115200 of the
Next. Using EDIT (SHIFT+1) on .UART or GRAPHICS (SHIFT+9) on TERMINAL you can
cycle through each option pressing enter until you see ERROR! (If you can see
the module then many have a little blue light that flashes when receiving)

Once you have that you should be able to type 'AT' and press ENTER.

That should give OK...

Probably the first thing you want to do is tell the module to use the default
speed of the next so type:

AT+UART=115200,8,1,0,0 and press ENTER

You now need to used EDIT (SHIFT+1) on V2 or GRAPHICS (SHIFT+9) on V3 to go back
around to 115200 so that [ENTER] gives ERROR and AT[ENTER] gives OK again....

We just used one of the AT commands...

AT+UART=<baudrate>,<databits>,<stopbits>,<parity>,<flow control>


Getting on the Network
----------------------

Now to do as Victor did and connect to a WIFI access point.

First let's check that the system is in STAtion mode:

AT+CWMODE=?  will give 1,2 or 3 (where STA=1, AP=2, Both=3)

Mode 1 or 3 is fine but, more config is needed in 2!

So just

AT+CWMODE=1  - to set it

AT+CWLAP - to List Access Points...

AT+CWJAP="wifinetwork","password" - To Join Access Point

Note that the module will retain the wifi connection and you can just do an 
AT+RST which will reset the module and give a CONNECTED and GOT IP.

AT+CIFSR will give the current IP address on the network.

AT+GMR will tell you the current versions of the software on your module.


Next you need to connect to something
-------------------------------------

AT+CIPSTART="TCP","www.google.com",80 is the example in the video

That is just the first stage and means there is now a pipe from the ESP to the
Google server.

Before it does anything you need to send it something.

If you do feel brave before you close the connection then you can send

AT+CIPSEND=7

at the ">" prompt which appears you should type:

"GET /" followed by 13 Carriage Return and 10 linefeed

I.E. Just press return twice...

AT+CIPSEND=length allows you to get the > prompt and type 'length' characters.

Incoming replies will be "+ IPD,length:" followed by the data. no space

Finally you will need to close down the connection:

AT+CIPCLOSE


That all looked to hard
-----------------------

This is very fiddly so .UART and TERMINAL include a mode called CIPSEND that
does all the decoding for you.

If you press INV VIDEO (SHIFT+4) then system will send an ATE0 to stop the ESP
echoing everything and then anything you type will be sent followed by a
Return and Newline.

You can also on TERMINAL use the EDIT (SHIFT+1) to go into immediate mode where
everything you type is sent as you do it.  In this mode to send a LF you need to
Symbol Shift + ENTER after pressing ENTER (or SHIFT and 6 / downarrow) to send
a  10 / LF / Newline.  This makes AT commands more complex but this mode is more
useful to use the program as a traditional text terminal.

Anything the other end replies with will just appear. Note that at 14MHz you
will get more text before the system begins to lose data due to the delays in
printing what is received.  Far more works on TERMINAL than .UART.

This mode is good enough to be a simple text terminal for a shell on a linux box
or any test system.

If you connect to Google again and use CIPSEND mode then send four lines EXACTLY
like this:

GET / HTTP/1.1\r\n
Host: www.google.com\r\n
Connection: close\r\n
\r\n

(where the \r\n represent what CIPSEND will do when you press ENTER)

Your screen will fill with the RAW data that makes up the very simple
Google home page...

So that's a bust then, the World Wide Web is just too advanced for the poor old
speccy. (maybe the PI accelerator will be able to help in the future...)

In order to get back to talking to the ESP you will now need to exit CIPSEND
mode by pressing INV VIDEO (SHIFT+4) again.


Let's try something different
-----------------------------

AT+CIPSTART="TCP","dict.org",2628

Should get you:

220 ..............some WELCOME.....

Go into CIPSEND mode with INV. VIDEO (SHIFT+4) and type:

DEFINE wn server\r\n

And you should get:

150 1 definitions retrieved
151 "server" wn "WordNet (r) 2.0"
server
     n 1: a person whose occupation is to serve at table (as in a
          restaurant) [syn: {waiter}]
     2: (court games) the player who serves to start a point
     3: (computer science) a computer that provides client stations
        with access to files and printers as shared resources to a
        computer network [syn: {host}]
     4: utensil used in serving food or drink
.
250 ok [d/m/c = 1/0/18; 0.000r 0.000u 0.000s]

Now send:

QUIT

and you will get

221 bye [d/m/c = 0/0/0; 16.000r 0.000u 0.000s]


I want the module to forget my WiFi network and password
--------------------------------------------------------

AT+CWQAP

Will close it all down if you do not want it to remember for next time.


So what else can you do at the moment with such a limited system?
-----------------------------------------------------------------

Truthfully not a lot yet - experimenting with connecting to text only services
is about it, as most modern systems use very complex sequences now that are hard
to type.

Until a few years ago you could have sent an e-mail but, due to spam most
servers need complex logins now!  Your ISP may allow simple SMTP but, it is 
unlikely...


This is nearly enough to get on an old BBS system
-------------------------------------------------

Info about the sinclair retro BBS which has a limited number of connections
(10 I think) run by Simone from Sinclair Software Preservation can be found at:

http://telnetbbsguide.com/bbs/sinclair-retro-bbs/

The CIPSTART connect you actually need to use it on a Next is: 

AT+CIPSTART="TCP","retrobbs.sinclair.homepc.it",23

Port 23 is Telnet for those in the know.

You can make a connection to this and it will stop with a prompt asking
you for a graphics mode buried among the control codes - and then kick you off
when you answer ASCII as ANSI is not supported.

A priority is to make the ANSI support good enough for us to login to this
server - watch the forum and fb for updates.

There are others around as well like http://www.mono.org/ many are
listed on the telnetbbsguide.


Using the WikiPedia telnet service
----------------------------------

Version 3 of the TERMINAL using IRQ driven UART can cope with a lot of
data now so it is possible to use WikiPedia at least from its text gateway

https://meta.wikimedia.org/wiki/Telnet_gateway

"TCP","telnet.wmflabs.org",23

Note that this gateway is experimental and is not always on - in fact it seems
to be off most of the time now which is a shame.


More reading on the ESP modules
-------------------------------

Some good guides to the module in general:

http://www.esp8266.com/wiki/doku.php?id=getting-started-with-the-esp8266

https://medium.com/@nowir3s/getting-started-with-esp8266-875fb54441d6

http://www.instructables.com/id/Getting-Started-With-the-ESP8266-ESP-01/

The full set of AT instructions is here (also linked on the SpecNext article):

http://www.espressif.com/sites/default/files/documentation/4a-esp8266_at_instruction_set_en.pdf

or more easily navigable onine:

https://room-15.github.io/blog/2015/03/26/esp8266-at-command-reference

Advanced dicsussion on the UART - the ESP has more advanced ones than ZX Next:

http://forgetfullbrain.blogspot.co.uk/2015/08/uart-sending-and-receiving-data-using.html


I need an ANSI terminal to connect to a BBS
-------------------------------------------

This is partially implemented but, diasabled in the current UART as it has
errors - it is possible that it will not be fully developed and it is more
likely that the ANSI system from Z88DK is used with the ESPAT full networking
support to create a terminal.

http://ascii-table.com/ansi-escape-sequences.php

There is minimum support for:

ESC[2J		- Erase display cursor to 0,0 (top left)
ESC[line;colH   - Move print position to line,col

Spectrum should be easy to do some of:

Esc[Value;...;Valuem 	Set Graphics Mode:
Calls the graphics functions specified by the following values. These specified
functions remain active until the next occurrence of this escape sequence.
Graphics mode changes the colors and attributes of text (such as bold and
underline) displayed on the screen.
 

Text attributes
0	All attributes off
1	Bold on
4	Underscore (on monochrome display adapter only)
5	Blink on
7	Reverse video on
8	Concealed on
 
Foreground colors
30	Black
31	Red
32	Green
33	Yellow
34	Blue
35	Magenta
36	Cyan
37	White
 
Background colors
40	Black
41	Red
42	Green
43	Yellow
44	Blue
45	Magenta
46	Cyan
47	White 


Making sure you have the latest firmware on the ESP:
----------------------------------------------------

Programming these using the Serial programmer is slightly complex and covered in
the above links - but, there is a built in function to do it once you have a
WiFi connection. Use at your risk the Author has done it a few time on a module
and it did work but, you need patience as the +CIPUPDATE:1-4 messages can take
several minutes - DO NOT TURN OFF DURING THIS.

Updating the ESP8266 over the air

# Update steps
1.Make sure TE(terminal equipment) is in sta or sta+ap mode

    AT+CWMODE=3
    OK

2.Make sure TE got ip address

    AT+CWJAP="ssid","12345678"
    OK
    
    AT+CIFSR
    192.168.1.134

3.Let's update

    AT+CIUPDATE
    +CIPUPDATE:1    found server
    +CIPUPDATE:2    connect server
    +CIPUPDATE:3    got edition
    +CIPUPDATE:4    start start
    
    OK

> NOTICE: If there are mistakes in the updating, then [the ESP will] break
update and print ERROR.

http://bbs.espressif.com/viewtopic.php?t=2613


Modern security means I cannot get a shell on a unix box using netcat -b
------------------------------------------------------------------------

Fifo's are your friend the whole world is your enemy so make sure you do
not expose your system...

rm -f /tmp/f;mkfifo /tmp/f
cat /tmp/f | /bin/sh -i 2>&1 | nc -l -p 10000 > /tmp/f

Also on netcat see:

https://www.g-loaded.eu/2006/11/06/netcat-a-couple-of-useful-examples/

This is the source of the dict.org example above!


Other security issues:
----------------------

Don't forget 
			
https://www.youtube.com/watch?v=Hkr60GE5yfY			
	
Now the other two wifi
	
https://www.raspberrypi.org/blog/why-raspberry-pi-isnt-vulnerable-to-spectre-or-meltdown/	


Notes from AA on timings to empty the buffer
--------------------------------------------

Once per frame should be enough

Are you waiting too long to check if data is available?  At 115200, it's a max
of 11.5k/s sent from the esp.  At 3.5MHz, that's about 300 cycles per byte sent.
I think you can get away with checking for data once per frame and draining the
Rx buffer.

The ESP-01 does have two gpio pins exposed so if the esp firmware is rewritten
you could use those for hw flow control.  I don't know if the default firmware
is able to do sw flow control but probably not [it can't]


Example Assembly Language to use the UART
-----------------------------------------

;The ports are 0x143b = 5179 for RX and BAUD rate and 0x133b = 4923 for TX and
;Status Test
;A read on the TX port shows the status of the FIFO buffer and the TX line:
;the bit 0 returning ‘1’ if the FIFO buffer is empty or ‘0’ if there is data to
;be collected.
;The bit 1 returns the TX status: ‘1’ when the TX still transmitting the last
;byte or ‘0’ and when the TX is idle.
;Bit 2 WILL BE Fifo full indicator

;-------Send bytes from (HL) terminated with LF (10)

tx_out:			
			LD DE,2048
;Delay timeout - was 20 at 112500 baud - need to be higher at lower baud rates...
						
			LD BC,TX_CHKREADY
tx_out_wait:		IN A,(C)
			AND @00000010		;Check if TX available for send
			JR Z,tx_out_ready	;, wait until it is or timeout.
					
			DEC DE
			LD A,D
			OR E
			JR NZ,tx_out_wait

			LD HL, str_TIMEOUT	;Prints an error if we not ready
			JP print
			
tx_out_ready:		LD A,(HL)
			OUT (c),a		
	
			CP 10
			RET Z

			INC HL
			JR tx_out

;------- Wait upto DE loops for data to be available in the UART buffer...		
			
GET_BYTE_WAIT:		LD DE,1000
			JR GET_BYTE_2

GET_BYTE:		LD DE,20

GET_BYTE_2:		LD BC,TX_CHKREADY
			IN A,(C)
			AND @00000001
;***TODO Change this to preserve BIT 2 to see if buffer was full
			JR Z,GET_BYTE_READY
			
			DEC DE
			LD A,E
			OR D
			JR NZ,GET_BYTE_2
			SCF
			RET			;We timed out
			
GET_BYTE_READY:	
;*** TODO check here if Bit 2 is a 1 and warn of possible data loss...
	
			LD A,14h		;143Bh - RX_SETBAUD
			IN A,(3Bh)		;Used as no effect on
						;Flags for Zero from above
			OR A			;CCF
			RET

Changes from TBU .29 onwards
----------------------------

An improvement in the BAUD rate setting has been made in the core to allow any
prescaler value you want - this means you now have to calculate adjustments
yourself for master clock timing differences when users select modes 0-7
VGA/HDMI

The advantage is that you can have a wider range of rates upto 2Mb! However, we
have only been able to verify upto 921600.. Also if the core timing changes for
any reason it is only a simple update to the lookup table below.

To set BAUD prescaler first write must be 0-127 which are the lowest 7 bits (the
0 in BIT 7 resets the value loader).  Second byte must be 1mmmmmml where l is
the 8th bit of the prescaler and mmmmmm is the top six bits of the prescaler
value (1 just stops the reset)

The previously undocumented Next register 0x11 (17) can be used to read the
selected display timing parameter.
I.e. OUT 9275,17 followed by IN 9531 (OUT 0x243B,0x11 IN 0x253B)
Victor used it to change the PLL
when X"11" => -- 17
		register_data_s 	<= "00000" & machine_video_timing;
This is needed to adjust the prescale value used to reflect the display timing
the user has selected or the highr speeds will never work.  Some of the lower
ones will.

BaudPrescale:

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

;Note that an ESP AT+UART_CUR? may return 115273 but, the pre-scaler values for
;that slight difference are identical 

;Cannot go to 1200 as requires a pre-scaler greater than the 14 bit register

;For info on why the faster rates will be less accurate and may not actually
;work...
;https://arduino.stackexchange.com/questions/296/how-high-of-a-baud-rate-can-i-go-without-errors

;So onto a code example for writing the Baud rates on the latest core and
;firmware.
;Assuming A is the baud number 0-14

			LD D,0
			SLA A		; *2
			RL D
			SLA A		; *4
			RL D
			SLA A		; *8
			RL D
			SLA A		; *16
			RL D	
			LD E,A		
			LD HL,BaudPrescale ; HL now points at the BAUD to use.
			ADD HL,DE

			LD BC,9275	;Now adjust for the set Video timing.
			LD A,17
			OUT (C),A
			LD BC,9531
			IN A,(C)	;get timing adjustment
			LD E,A
			RLC E		;*2 guaranteed as <127
			LD D,0
			ADD HL,DE

			LD E,(HL)
			INC HL
			LD D,(HL)
			EX DE,HL

			PUSH HL		; This is prescaler
			PUSH AF		; and value
						
			LD BC,RX_SETBAUD
			LD A,L
			AND %01111111	; Res BIT 7 to req. write to lower 7 bits
			OUT (C),A
			LD A,H
			RL L		; Bit 7 in Carry
			RLA		; Now in Bit 0
			OR %10000000	; Set MSB to req. write to upper 7 bits
			OUT (C),A

			POP AF		; Restore damaged values
			POP HL

The TERMINAL program changes the BAUD setting to the GRAPHICS key (SHIFT+9) so
that the EDIT (SHIFT+1) can more usefully be used to cycle between line edit and
direct, with and without local echo, for Tormod.

.UART(22c) Retains the old code and controls but allows the new baud rate
handling. This is provided for backwards compatability with the new cores and
ESXDOS.

Note that these programs will no longer be developed in favour of using the new
ESPAT loadable NextOS drivers. They are retained in the pack though for
use of the UART for other purposes (UART.DRV) and for use under ESXDOS (.UART).
			
Tim Gilberts - August 2018

