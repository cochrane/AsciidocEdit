asciihelper (v0.1)
==================

Asciihelper is a MacOS application for helping to compose 
documents written in asciidoc markup.  Two panes are
shown side-by-side in the main window.  On the left
is the source file (asciidoc).  On the right is the
html rendered from it.  Type cmd-S to save and render.

See the screenshot in the images directory for this repo.

Asciihelper is written in Swift.  It calls on 
[Asciidoctor](http://asciidoctor.org) to process
the source file. (It calls
`/usr/bin/asciidoctor`)

Installation
============

Clone and compile project with XCode. You must have `/usr/bin/asciidoctor`
set up for `asciihelper` to work.

Issues
======

**Menu Items:**

- "Save as PDF" may not work because of `asciidoctor-pdf` installation
issues.

- "Install Asciidoctor" does not work and may never work becaue
of sandbox and permission issues.  If I can't solve this one,
I will eliminate this menu item.


Planned features
===============

Distribution
============

This app will be distributed on the appstore
for free when it is suitable for "publication".  Source
code will remain here and the app can always be compiled
from the source.


License
=======

MIT License
