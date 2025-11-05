# Parser

Uses a two-phase strategy:

- take the markdown source and split it into lines then category them by type
    - paragraphs, headings, lists, empty lines, etc
- compose the lines for each type, in the same order as they were categorized
