This folder contains

- `sub.rb` 
- `test.ad`

The purpose of `sub.rb` is to apply substitions
the the text of the input file, in this case
transforming usual TeX syntax into Asciidoc
syntax.  The mappings are

- `$ (a^2)^3 = a^6 $      ==> +\( (a^2)^3 = a^6 \)+`

- `\( (a^2)^3 = a^6 $ \)  ==> +\( (a^2)^3 = a^6 \)+`

- `\[ (a^2)^3 = a^6 $ \]  ==> +\[ (a^2)^3 = a^6 \]+`

in that order.

To run `sub.rb` on `test.ad`, do this:

- `ruby sub.rb test.ad test2.rb`

- `asciidoctor test2.ad`

- View `test2.html` in a browser

Or better, replace the last two steps by viewing
`test2.ad` in Chrome with asciidoctor-chrome-extension
installed.

I would eventually like to implment this kind of preprocessing
via an asciidoctor extension if I can figure out how to do that.


