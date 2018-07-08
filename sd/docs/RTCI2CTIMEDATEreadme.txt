These are Updated versions of the TIME, DATE and RTC.SYS files from:

https://gitlab.com/victor.trucco/RTC

This release includes .TIME Version 3.3

They have been debugged and adapted for the ZX Next by Tim Gilberts
This is the second Pulic BETA release but, they have been tested...
The ASM is now modified to assemble with z80asm from Z88DK.

They operate as DOT commands so just place DATE, TIME and I2CSCAN in
the /BIN directory. See later for how to create a suitable RTC.SYS.

If you use these without a Real Time Clock (RTC) soldered to the board
they will just give an error that no signature is found or No ACK received

You can however use the option TIME -d to get the contents of the chip
which will be junk if the RTC is not fitted but, may help to diagnose
any problems getting it working.

You can use the DATE and TIME commands without RTC.SYS to just set and
query the date and time respectively.  They expect the RTC to be in
24 hour mode and make use of the last two RAM storage locations, so do
not use these.  Any write of a DATE or TIME will set the signature.

If you place a file called RTC.SYS in the 'nextos' folder then from 1.92
onwards all files you create or update from then on will contain a date
and time if the clock contents are valid. It does not have to be the
correct time and date just valid in the range of 2000-2099.

This will also make the date and time appear in the NextOS menus
automatically.  If you do not wish to use them then you can rename or
remove RTC.SYS from the folder or use TIME -di to wipe the signature - if
using RTCSIG.SYS.

If you want the same facilities in ESXDOS then place a file called RTC.SYS
in the /SYS directory (the RTCSIG.SYS version is compatible with both OS).
Note this will only work with ESXDOS 0.8.6Beta2 and above.  ESXDOS does
not change the date and time on update I belive only on create.

Option -h is available on both commands to show you the simple syntax.
The strings for date and time must now use quotes to be valid.

e.g.

.DATE "31/12/2017"  	- will set the date to new years eve.

.DATE			- will just print the current date

.TIME "00:30:00:	- will set the time to 30 minutes after midnight

.TIME -h		- will print its help

.ls			- will display the dates of files on NextOS/ESXDOS

cat exp			- Will give the time stamp as well on NextOS

Notes on the physical devices
-----------------------------

Note that the specification sheet asks for a Crystal of 12pF - The author
has one at 6pF and it seems to perform - YMMV.

The Author has several DS1307 chips and NOT ONE OF THEM allows RAM location
0x15 to be written - THIS MAY BE A BUG in the i2csystem - feedback is encouraged
(on the other hand it could just be cheap chips).

Using commands from BASIC
--------------------------

You can get the contents of a dot command into a string using this clever
trick in NextBASIC from Mr Garry Lancaster:

DIM a$(100):OPEN #2,"v>a$":.TIME:CLOSE #2:PRINT a$

Then you can use string commands to cut out whatever bits you want!

You can effectively "touch" a file in BASIC with  OPEN #4,"u>filename":CLOSE #4


ESXDOS Support
--------------

These commands do work with ESXDOS Beta 2 onwards 

http://esxdos.org/beta/esxdos086-BETA4.zip

See development log here (current version is BETA6 I believe):

http://board.esxdos.org/viewtopic.php?id=5

Note that only the RTCSIG.SYS file can be used as there is a size limit
of 256 Bytes.  This means you can only use the DS1307 chip.

Other RTC clocks
----------------

As of TIME version 3.3 there is LIMTED support for a DS3231 module to be
connected to the I2C bus on the J15 GPIO pins.

(You can of course connect a DS1307 based module there as well if you want
to do less soldering on your board as only four connections are needed)

This has to be done the hard way; setting and reading registers by hand as
there is no RAM, a signature cannot be used. Counts and Register addresses
are in Hex but time is BCD so human readable.

So:

time -w00SSMMHHWWDDMMYY

will set the Seconds,Minutes,Hours,Dayofweek,Day,Month,Year

and

time -r1300

will read the status of the 19 regsiters 00-06h Time, 07-0dh Alarm, 
0E-10h Control and 11h/12h MSB/LSB of Temperature

In order for NextOS to recognise the time from this module for its
clock and timestamping of files you need RTCACK.SYS and a version
of NextOS that supports 512Byte SYS modules i.e. >=1.94c.

Replace RTC.SYS in the NextOS folder with a renamed copy of RTCACK.SYS
which uses only the ACK on the bus for detection and some sanity checks
on the numbers returned.  This version works with the DS1307 as well but,
is currently BETA only.

WARNING: This version of RTCACK.SYS DOES NOT WORK ON ESXDOS only NextOS
which of course implies that the DS3231 is only supported on NextOS
leaving the old RTC.SYS (a renamed copy of RTCSIG.SYS) installed on
ESXDOS should not affect the DS3231 module - you will just not get
timestamps.  You can use Victor's original code as it should work with
both chips I think but, you will only get DATE stamps and not time.

Utilities
---------

Also supplied is a DOT command called I2CSCAN - this will search the
i2c bus for any devices found which can help in seeing what is connected.
You should see at least one device at 0x68 if the RTC chip is connected.
The DS3231 module may have a fan out extender so you may also see a device
at 0x57.  If you see others when you have nothing on J15 then make sure you
have the latest TBU, any Capacitor mod etc - if so and you still have others
detected then please contribute to the RTC posts on Facebook or the Forum.

You can also use the .TIME command to see the output from the NextOS RTC API
using the -n option - this should be substantially the same as the figures
for BC and DE calculated by the .TIME -d command.  They may vary as at least
a second or so could have elapsed even if you do cls:.time -d:.time -n.  This
feature will obviously have an indeterminate effect on ESXDOS.


