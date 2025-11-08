# Parser

Uses a two-phase strategy:

- take the markdown source and split it into lines then category them by type
    - paragraphs, headings, lists, empty lines, etc
- compose the lines for each type, in the same order as they were categorized

## output

should decide the output format of the parser, which could be a `Block`

besides parsing and assemblying the blocks(title, tags, ingredients), we also
need some metadata, which for now it should be the filenames' of the source

## two scope

the parser could be used in 2 ways:

- validate a recipe's required fields(title, tags, ingredients)
- expose the important fields
    - will extract the raw value of the text, preserving tags(`#`, `-` for lists, etc)
    - need the bare minimum for this stage

## grouping lines

each target line needs to be grouped together, ingredients with its following list or paragraphs,
tags followed by a list; the only one who stands out is the heading, which doesn't have a companion.

- start at the first line
- if it's a heading, extract it
    - if theres another heading already in parsing
        - previous stage is done, move to next one
    - extract list or paragraph
    - consume until you hit a new heading
- if it's a paragraph or list
    - see which heading you're on(eg: ingredients, tags, etc)
    - consume the text
