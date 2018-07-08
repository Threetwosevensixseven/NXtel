Interrupt driven mouse driver for ZX Next
-----------------------------------------

This is designed to be a demonstration of a
use for the new Driver API that is included
in NextOS 1.95 on which allows upto 512 bytes of
interrupt code to be added to the standard
Spectrum interrupt system - the one that reads
the keyboard every 1/50th of a second.

All you need is the file MOUSE.DRV in the NEXTOS
folder and a version of NextOS 195 or greater.

The driver can then be controlled from BASIC
with the new DRIVER command.

This mouse driver is driver number 126. There
will be a supported list of driver codes and
any that use streams (this does not) will need
to be allocated one from 65-90 A-Z or the lower
case range (or both) so this avoids that area.


To use you need to install the driver. Which
expects the install and uninstall DOT commands
in the BIN directory.

.install /nextos/mouse.drv


It supports the following parameters for driver

DRIVER 126,1 TO button,x,y

Will get the current location of the mouse on a
192 x 640 grid with 0,0 in the top left of the
outer border where sprites can go.  It uses the
higher X number to allow use in Timex mode where
there are twice as many horizontal pixels


DRIVER 126,2{,sprite{,pattern}}

Where the optional sprite number 0-63 and pattern
number 0-63 will default to 0 and will cause that
sprite to always be displayed (anywhere that clipping
is not in effect) at the current X,Y coordinate
- over a timex screen it will sit between two pixels
of course.

DRIVER 126,3

Will disable the sprite cursor.

DRIVER 126,4{,attribute}

will display an Attribute based character cursor using
the ULA attributes - this will cope with some screen
changes but, not scrolling so remember to disable it
when changing the screen wholesale.

So using the new features of NextOS to include a 
binary number (@) in an integer statement (%)

DRIVER 126,4,%@11100111

Will set a Bright, Flashing, Green and White cursor.
the first two 1's are Bright and Flash the next two
groups of three are the paper and ink.

FTGRBGRB - where T-Bright.

DRIVER 126,5

will remove the Attribute based cursor.

There is a demo program called NXMOUSE2.BAS that uses
the above features for you to play with. It uses the
sprites from the BREAKOUT test but, you can change line
300 to load any set you wish.  Note that if you
hold the 's' button and move it around at times the
sprite cursor will seem to disappear that is because you
have reached the maximum 16 sprites per display line.

You could modify the code to remove the tail of previously
used sprites if you want but, it is quite fun to play with.

The scrappy source code is provided in case you want to play
with it and is assembled exactly like the Border demo. This
may be developed as time goes on.

Tim Gilberts
Feb 2018

