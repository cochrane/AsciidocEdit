This folder contains

- `tex_mode_preprocess` 
- `test.ad`

The purpose of `tex_mode_preprocess`, a ruby script,
is to apply substitions to
the text of the input file, in this case
transforming usual TeX syntax into Asciidoc
syntax.  The mappings are

- `$ (a^2)^3 = a^6 $      ==> +\( (a^2)^3 = a^6 \)+`

- `\( (a^2)^3 = a^6 $ \)  ==> +\( (a^2)^3 = a^6 \)+`

- `\[ (a^2)^3 = a^6 $ \]  ==> +\[ (a^2)^3 = a^6 \]+`

in that order.

To run `tex_mode_preprocess` on `test.ad`, do this:

- `./tex_mode_preprocess test.ad test2.rb`

- `asciidoctor test2.ad`

- View `test2.html` in a browser

Or better, replace the last two steps by viewing
`test2.ad` in Chrome with asciidoctor-chrome-extension
installed.

**Note.** You can run the preprocessor directly from `AsciidoctorEdit`.
To do, copy`tex_mode_preprocess` to `usr/local/bin` and make
sure that it is executable (`chmod u+x tex_mode_preprocess`).

I would eventually like to implment this kind of preprocessing
via an asciidoctor extension if I can figure out how to do that.


