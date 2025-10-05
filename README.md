# Haplea

A multi-feature Rust application combining markdown parsing, mDNS service discovery, and HTTP server capabilities.

## Project Structure

```
haplea/
├── Cargo.toml                    # Workspace root
├── crates/
│   ├── haplea/                   # Main binary application
│   │   ├── src/
│   │   │   ├── main.rs           # Entry point with CLI
│   │   │   ├── config.rs         # Configuration and CLI args
│   │   │   ├── discovery/        # mDNS service discovery
│   │   │   └── server/           # HTTP server
│   │   └── Cargo.toml
│   ├── haplea-parser/            # Markdown parsing library
│   │   ├── src/lib.rs
│   │   └── Cargo.toml
│   └── haplea-common/            # Shared types and utilities
│       ├── src/
│       │   ├── lib.rs
│       │   ├── error.rs          # Error types
│       │   └── types.rs          # Common types
│       └── Cargo.toml
├── frontend/                     # React + TypeScript web client
│   ├── src/
│   ├── libs/                     # Frontend shared utilities
│   └── package.json
└── scripts/                      # Build and automation scripts
```

## Features

### 🔍 mDNS Service Discovery
Discover and advertise services on the local network using the `mdns-sd` crate.

### 🌐 HTTP Server
Simple HTTP server built with Axum, serving a web interface and API endpoints.

### 📝 Markdown Parsing
Parse markdown files using `pulldown-cmark` for recipe storage and rendering.

## Development

### Prerequisites
- Rust 1.70+ (install via [rustup](https://rustup.rs/))
- Node.js 18+ (for frontend development)

### Building the Rust Workspace

```bash
# Build all crates
cargo build

# Build in release mode
cargo build --release

# Run the main binary
cargo run --bin haplea

# Run with options
cargo run --bin haplea -- --enable-discovery --port 3000
```

### Testing

```bash
# Test all crates
cargo test

# Test specific crate
cargo test -p haplea-parser
cargo test -p haplea-common
cargo test -p haplea
```

### Running Individual Crates

```bash
# Build just the parser
cd crates/haplea-parser && cargo build

# Test just the parser
cd crates/haplea-parser && cargo test
```

### Frontend Development

```bash
cd frontend
npm install
npm run dev
```

## CLI Usage

```bash
haplea [OPTIONS]

Options:
  --enable-discovery     Enable mDNS service discovery
  --enable-server        Enable HTTP server (default: true)
  -p, --port <PORT>      HTTP server port (default: 3000)
  --service-name <NAME>  Service name for mDNS (default: haplea)
  -h, --help             Print help
```

## Architecture

The project follows a **Cargo workspace** architecture for better:
- **Separation of concerns**: Each crate has a single responsibility
- **Independent testing**: Test each component in isolation
- **Reusability**: Libraries can be used independently
- **Development speed**: Build and test only what you need

## License

MIT
