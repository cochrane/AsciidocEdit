asciihelper
===========

Asciihelper is a MacOS application for helping to compose 
documents written in asciidoc (asciidoctor) markup.
It is written in Swift. Although it works at a very basic
level, it has a long ways to go, especially in 
doing a good live preview of the asciidoc text.

See the screenshot in the images directory for this repo.

The app has two windows.  On the left, a basic text
editor which displys the source file, e.g `foo.ad`  
On the right is a window which displays the file
`foo.html` which `asciidoctor` produces from `foo.ad`.

Whe you do cmd-S, `asciihelper` calls on `asciidoctor`
to render `foo.ad` as `foo.html`.  (It calls
`/usr/bin/asciidoctor`).

At the moment the biggest issue is a "lag" in refreshing
the WebView (right-hand windowpane).  When you do cmd-S,
the text on the left is saved and `asciidoctor` is run 
on it.  However, for some reason you have to do cmd-S
**twice** to see the rendered output.  If someone
could help out on this, that would be great.

Installation
============

Clone and compile project with XCode. You must have `/usr/bin/asciidoctor`.

Note
====

This app will be distributed free on the appstore
when it is suitable for "publication".  Source
code will remain here and the app can always be compiled
from the source.


License
=======

MIT License
