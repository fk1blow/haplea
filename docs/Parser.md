# Parser

Uses a two-phase strategy:

- take the markdown source and split it into lines then category them by type
    - paragraphs, headings, lists, empty lines, etc
- compose the lines for each type, in the same order as they were categorized

## output

should decide the output format of the parser, which could be a `Block`

besides parsing and assemblying the blocks(title, tags, ingredients), we also
need some metadata, which for now it should be the filenames' of the source
