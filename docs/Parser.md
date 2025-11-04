# Parser

a paragraph ends when:

- theres a line that containts only one character: '\n'
- a line has only empty spaces

```
This is a paragraph.
Still the same paragraph.

The empty line above ended the paragraph, so we get a new paragraph.
```

paragraphs followed by block elements:

```
This is a paragraph.
Still the same paragraph.
# This is a heading

The heading above ended the paragraph, even without a blank line.
```
