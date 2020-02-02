NXTEL
=====
NXtel is a viewdata TCP/IP client, server and page manager for the ZX Spectrum Next™.

See the FAQ at: https://github.com/Threetwosevensixseven/NXtel/wiki/FAQ

BUILDING FROM SOURCE
====================

To build NXTP on Windows 10 from source you obtained from the ZX Spectrum Next™ distro or gitlab repository:

DO THIS ONCE:
-------------
Browse to the "build" directory.
Doubleclick on "get-tools.bat".
Wait while four tools are downloaded. The last, "zeustest.exe" is 1.6MB, so be patient.
When prompted "Press any key to continue", press a key.

DO THIS EVERY TIME YOU WANT TO BUILD:
-------------------------------------
Browse to the "build" directory.
Doubleclick on "zeustest.exe".
Do File >> Open, then browse to the "src" directory.
Select "main.asm" and click the Open button.
In Zeus, on the "Zeus (assembler)" tab, click the Assemble button.
The dot command will be build in the "dot" folder as "NXTP".
Copy this file to the dot folder on your Next SD card.

LICENCE (GPL-3.0)
=================
NXtel is copyright © 2018-2020 Robin Verhagen-Guest.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see:
https://github.com/Threetwosevensixseven/NXtel/blob/master/LICENSE

NXtel source code for the Spectrum Next client, server, page manager
is available at: https://github.com/Threetwosevensixseven/NXtel
Source code for the Spectrum Next client is also included in the
Next distro, available at: https://www.specnext.com/latestdistro/

Source code for NXtel, or any of the third party software listed below
in the Third Party Licences section, can also be obtained by emailing:
robin.verhagen.guest@gmail.com

THIRD PARTY LICENCES
====================
NXtel includes code from the following projects, with grateful thanks:

BeepFX
------
BeepFX player Copyright 2011 Shiru

This software is provided under the terms of the WTFPL v2 license. You are free to use it without any limitations, without any warranty

BeepFX source code for the player and a Windows sound effect editor are also available at: https://shiru.untergrund.net/software.shtml

ZX7
---
"ZX7" is an optimal LZ77/LZSS data compressor for all platforms, including the ZX-Spectrum.

ZX7 is Copyyright 2012 Einar Saukas.

ZX7 source code is also available at: https://spectrumcomputing.co.uk/index.php?cat=96&id=27996

FZX
---
NXtel uses the FZX font format. No code is used from the FZX font driver but inspiration is gratefully ackknowledged.

FZX font format - Copyright (c) 2013 Andrew Owen
FZX font driver - Copyright (c) 2013 Einar Saukas

FZX is a royalty-free compact font file format designed primarily for storing bitmap fonts for 8 bit computers, primarily the Sinclair ZX Spectrum, although also adopting it for other platforms is welcome and encouraged!

You can freely use the FZX driver code in your programs (even for commercial releases), or adapt this code according to your needs. In particular, porting this code to other platforms is permitted and encouraged.

The only requirement is that you must clearly indicate in your documentation that you have either used this code or created a derivative work based on it.

The FZX font format is an open standard. You can freely use it to design and distribute new fonts, or use it inside any programs (even commercial releases). The only requirement is that this standard should be strictly followed, without making irregular changes that could potentially cause incompatibilities between fonts and programs on different platforms.

FZX source code and format specification is also available at: https://spectrumcomputing.co.uk/index.php?cat=96&id=28171

TRADEMARKS
==========

ZX Spectrum Next is a trademark of SpecNext Ltd.
