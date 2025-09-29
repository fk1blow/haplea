# Haplea

A minimal, efficient, search-driven food recipe app powered by Rust (WASM), React (Vite), and GitHub for recipe storage.

## Project Goals

- Fast recipe search and display using a modern stack.
- Markdown-based recipes stored and versioned on GitHub.
- Parsing and processing of Markdown via Rust compiled to WebAssembly.
- Frontend in React + TypeScript with Vite.
- Clean monorepo structure for easy development and deployment.

---

## TODO List

#### Rust WASM Parser (`parser/`)
- Bootstrap Rust crate with `wasm-bindgen` and `pulldown-cmark`
- Implement Markdown parsing logic for recipes
- Define a recipe data structure (title, ingredients, steps, etc.)
- Expose parsing functions to JS via WASM
- Write unit tests and WASM tests (`wasm-bindgen-test`)
- Optimize for WASM (bundle size, performance)

#### Frontend (`frontend/`)
- Bootstrap React + Vite + TypeScript app
- Implement recipe search UI (input, results list)
- Integrate Rust WASM parser (load, call from JS)
- Fetch Markdown recipes from GitHub repo
- Parse recipes with WASM, display parsed data
- Handle loading/error states
- Add basic styling (responsive, clean)
- Add recipe detail view

#### GitHub Integration
- Decide on recipe storage repo/structure (e.g., `recipes/*.md`)
- Implement GitHub API fetching for Markdown files
- Handle caching and rate limits
- Document recipe Markdown format

#### Shared Libs (`libs/`)
- Add basic shared types (Recipe interface, etc.)
- Expand shared types/utilities if needed

#### Tooling & Automation
- Add `.gitignore` and repo setup scripts
- Add build and test scripts for parser and frontend
- Consider adding CI/CD workflow (GitHub Actions)

#### Testing
- Write unit tests for Rust parser
- Write frontend component tests
- Integration tests for parser + frontend

#### Documentation
- Update README with usage, setup, architecture diagram
- Add contributing guidelines
- Add FAQ/Troubleshooting

#### Stretch Goals
- User authentication for recipe submission/edit
- Recipe images/media support
- Advanced search/filtering
- Mobile-friendly UI
- Deploy to production (Netlify/Vercel etc.)

---

## Quick Start

See `scripts/build.sh` for build instructions.

---

## License

Unlicense