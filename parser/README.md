# Parser (Rust WASM)

This crate provides a Markdown recipe parser compiled to WebAssembly (WASM) for use in the food-recipes-app.

## Build (for WASM)

```
wasm-pack build --target web
```
- Compiled artifacts will be placed in `pkg/`.

## Usage

Import the WASM package in your frontend (React/Vite/TypeScript):

```typescript
import init, { parse_recipe } from "../../parser/pkg/parser";
```

## Tests

### Native Rust unit tests

```
cargo test
```

### WASM tests (in browser or Node)

```
wasm-pack test --headless --chrome
```

Make sure you have `wasm-bindgen-test` as a dev-dependency.

## Directory Structure

- `src/lib.rs`: Library root, exports parser functions via wasm-bindgen.
- `tests/`: Unit and WASM tests.
