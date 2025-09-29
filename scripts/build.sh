#!/bin/bash
# Example build script stub

echo "Building parser (Rust WASM)..."
cd ../parser
wasm-pack build --target web

echo "Building frontend (React)..."
cd ../frontend
npm run build
