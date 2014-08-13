asciihelper
===========

Asciihelper is a MacOS application for helping to compose 
documents written in asciidoc markup.  Two panes are
shown side-by-side in the main window.  On the left
is the source file (asciidoc).  On the right is the
html rendered from it.  You will find he html file in
the same directory as the source file.   

Type cmd-S to save and render.
See the screenshot in the images directory for this repo.

Asciihelper is written in Swift.  It calls on 
[Asciidoctor](http://asciidoctor.org) (`/usr/bin/asciidoctor`) to process
the source file. 

This is version 0.1

Installation
============

Clone and compile project with XCode, v6.0 or later. You must have `/usr/bin/asciidoctor`
set up for `asciihelper` to work.  See [Asciidoctor](http://asciidoctor.org)

Issues
======

**Menu Items:**

- "Save as PDF" may not work because of `asciidoctor-pdf` installation
issues.

- "Install Asciidoctor" does not work and may never work becaue
of sandbox and permission issues.  If I can't solve this one,
I will eliminate this menu item.

- "File > MoveTo" has not been implemented yet


Planned features
===============

- Multiple windows

- epub3 export


I welcome suggestions


Distribution
============

This app will be distributed on the appstore
for free when it is suitable for "publication".  Source
code will remain here and the app can always be compiled
from the source.


License
=======

MIT License
