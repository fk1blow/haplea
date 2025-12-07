# Haplea

A recipe manager built with Zig and React. Compiles to a single binary with embedded frontend.

## Features

Store and search food recipes locally. Write recipes in markdown, search by ingredients or tags, and access everything through a simple web UI.
Compiles to a single binary with the frontend embedded.

## Project Structure

```
haplea/
├── build.zig              # Build configuration
├── build.zig.zon          # Package dependencies (http.zig)
├── src/
│   ├── main.zig           # HTTP server entry point
│   ├── embedded_assets.zig # Embedded frontend files
│   ├── recipe_parser.zig  # Recipe markdown parsing
│   ├── reverse_index.zig  # Full-text search indexing
│   ├── markdown/          # Generic markdown parser
│   ├── text/              # Text processing utilities
│   └── static/            # Embedded frontend assets (generated)
├── frontend/              # React + TypeScript + Tailwind
│   ├── src/
│   │   ├── App.tsx        # Main recipe display component
│   │   └── index.css      # Tailwind styles
│   ├── package.json
│   ├── tailwind.config.js
│   └── vite.config.ts
└── docs/
    └── recipe-examples/   # Example recipe files
```

## Prerequisites

- **Zig** 0.13+ ([ziglang.org](https://ziglang.org/download/))
- **Bun** 1.0+ ([bun.sh](https://bun.sh/)) - for frontend development

## Build Workflow

### Quick Start

```bash
# 1. Install frontend dependencies
cd frontend && bun install && cd ..

# 2. Build frontend
cd frontend && bun run build && cd ..

# 3. Copy assets for embedding
mkdir -p src/static/assets
cp frontend/dist/index.html src/static/
cp frontend/dist/assets/* src/static/assets/

# 4. Build Zig binary
zig build

# 5. Run
./zig-out/bin/haplea
```

Then open http://127.0.0.1:3000

### Development

```bash
# Frontend dev server (hot reload)
cd frontend && bun run dev

# Run Zig tests
zig build test

# Build release binary
zig build -Doptimize=ReleaseFast
```

### Full Rebuild

```bash
# Clean everything
rm -rf zig-out .zig-cache frontend/dist frontend/node_modules src/static

# Rebuild from scratch
cd frontend && bun install && bun run build && cd ..
mkdir -p src/static/assets
cp frontend/dist/index.html src/static/
cp frontend/dist/assets/* src/static/assets/
zig build
```

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
