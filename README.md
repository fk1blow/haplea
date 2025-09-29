# Food Recipes App

A minimal, search-driven food recipe app.

## Structure

- `parser/`: Rust crate for Markdown recipe parsing (compiled to WASM).
- `frontend/`: React + TypeScript web client.
- `libs/`: Shared code (TS types, JS utilities, etc).
- `scripts/`: Build and automation scripts.

## Usage

- Recipes are stored in Markdown files in a GitHub repo.
- On app open: fetch recipes from GitHub, parse using Rust WASM.
- Frontend provides search and displays recipes.

## Build

See `scripts/build.sh`.
