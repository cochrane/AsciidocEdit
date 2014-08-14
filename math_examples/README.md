This folder contains exampls of mathematical composed with AsciidocEdit.

- `periods.ad`: a short file with a set of tex macros at the end. This example shows
how to include tex macros in your document.  The tex macro definitions should
be put at the top of the file, before the main content

- `cag.ad`: a long file whose last nonblank line is `include::tex_macros.ad`.  This example
shows how to include an external macro package.  The include directive should
be put at the top of the file, before the main content

- `cag`: this is a folder with the content of `cag.ad` organized with one section per file
and one file `master.ad` which call the section files in using the `include` directive.

- `tex_macros.ad`: the tex macros used above.
 
