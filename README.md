# Haplea

A _wannabe_ recipe manager built with Zig and React. ~Compiles~ It should compile to a single binary with embedded frontend.

Theres not much to see, unfortunately, but it was a fun toy project which explored a few interested topics:
- parsing markdown
- building a reverse index
    - what is it
    - how to build one using zig
- research on information retrieval, like ranking
    - bm25/idf
    - ranking
    - ngrams
- learning zig and having fun

## Prerequisites

- **Zig** 0.15+ ([ziglang.org](https://ziglang.org/download/))

### Quick Start

```bash
# 1. Install frontend

## Recipe Format

Recipes are markdown files with specific sections:

```markdown
# Recipe Title

Short description of the dish.

## category

mains

## tags

italian, pasta, quick, comfort-food

## ingredients

- 400g spaghetti
- 4 large eggs
- 100g pecorino romano

## instructions

Cook pasta in salted water. Mix eggs with cheese...

## notes

Optional tips and variations.
```

**Required sections**: title (h1), tags, ingredients

## Tests

```bash
# Run all tests
zig build test

# Test coverage:
# - src/markdown/parser.zig - Markdown parsing
# - src/recipe_parser.zig - Recipe extraction
# - src/reverse_index.zig - Search indexing
```

## License

MIT
