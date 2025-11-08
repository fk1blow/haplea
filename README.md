# Haplea

A multi-feature Zig application combining markdown parsing, mDNS service discovery, and HTTP server capabilities.

## Project Structure

```
haplea/
├── build.zig                 # Build configuration
├── build.zig.zon             # Package dependencies
├── src/
│   ├── main.zig              # Entry point with CLI
│   ├── config.zig            # Configuration and CLI args
│   ├── discovery/            # mDNS service discovery
│   ├── server/               # HTTP server
│   ├── parser/               # Markdown parsing
│   └── common/               # Shared types and utilities
├── frontend/                 # React + TypeScript web client
│   ├── src/
│   ├── libs/                 # Frontend shared utilities
│   └── package.json
└── scripts/                  # Build and automation scripts
```

## Features

### mDNS Service Discovery

Discover and advertise services on the local network.

### HTTP Server

Simple HTTP server serving a web interface and API endpoints.

### Markdown Parsing

Parse markdown files for recipe storage and rendering.

## Development

### Prerequisites

- Zig 0.15+ (install from [ziglang.org](https://ziglang.org/download/))
- Node.js 18+ (for frontend development)

### Building the Project

```bash
# Build the project
zig build

# Build in release mode
zig build -Doptimize=ReleaseFast

# Run the application
zig build run

# Run with options
zig build run -- --enable-discovery --port 3000
```

### Testing

```bash
# Run all tests
zig build test

# Run tests with output
zig build test --summary all
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

## License

MIT
