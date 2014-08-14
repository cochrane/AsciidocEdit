This folder contains exampls of mathematical composed with AsciidocEdit.

- `periods.ad`: a short file with a set of tex macros at the end. This example shows
how to include tex macros in your document.  The macro definitions can be put anywhere,
with the head and tail of the document being the logical choices.  The tail is the better
choice because then you do not see (however briefly) the macro definitions during the 
typesetting process.

- `cag.ad`: a long file whose last nonblank line is `include::tex_macros.ad`.  This example
shows how to include an external macro package.

- `tex_macros.ad`: the tex macros used above.
 
