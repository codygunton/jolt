# AI Documentation - Jolt CLI

## Overview
This directory contains the main Jolt CLI application source code. Jolt is a zero-knowledge virtual machine (zkVM) that provides RISC-V instruction lookups with SNARK proofs. The CLI serves as the primary interface for creating new Jolt projects, managing toolchains, and building WASM-compatible outputs.

## Architecture
The Jolt CLI is built as a command-line tool using the clap crate for argument parsing. It provides several key commands for project management and toolchain operations.

## Key Components

### lib.rs (src/lib.rs:1-3)
Simple re-export module that exposes the core Jolt functionality:
- Re-exports `jolt_core` - the main zkVM implementation
- Re-exports `jolt_sdk` - the software development kit for building Jolt applications

### main.rs (src/main.rs:1-268)
Main CLI application with the following commands:
- **New**: Creates new Jolt projects with optional WASM compatibility
- **InstallToolchain**: Installs required RISC-V toolchains for Rust
- **UninstallToolchain**: Removes RISC-V toolchains
- **BuildWasm**: Handles preprocessing and generates WASM compatible files

#### Key Functions:
- `create_project()` (src/main.rs:62-69): Sets up project structure and files
- `create_folder_structure()` (src/main.rs:84-91): Creates directory hierarchy
- `create_host_files()` (src/main.rs:93-108): Generates host application files
- `create_guest_files()` (src/main.rs:110-121): Creates guest program files
- `display_welcome()` (src/main.rs:123-127): Shows ASCII art and system info

#### Project Templates:
The CLI includes embedded templates for new projects:
- `HOST_CARGO_TEMPLATE`: Cargo.toml template for host applications
- `HOST_MAIN`: Main.rs template with Fibonacci proof example
- `GUEST_CARGO`: Guest Cargo.toml configuration
- `GUEST_LIB`: Guest library with provable Fibonacci function
- `GUEST_MAIN`: Guest main.rs template

### build_wasm.rs (src/build_wasm.rs)
Handles WASM-specific build operations and Cargo.toml modifications for WASM compatibility.

### ascii/jolt_ascii.ans
ASCII art logo displayed during toolchain installation.

## Dependencies
Key external dependencies:
- `clap`: Command-line argument parsing
- `eyre`: Error handling
- `rand`: Random greeting selection
- `sysinfo`: System information display
- `jolt-core`: Core zkVM functionality
- `jolt-sdk`: SDK for building Jolt applications

## Usage Examples

### Creating a New Project
```bash
jolt new my-project
jolt new my-wasm-project --wasm
```

### Toolchain Management
```bash
jolt install-toolchain
jolt uninstall-toolchain
```

### WASM Build
```bash
jolt build-wasm
```

## Project Structure Generated
When creating a new project, the CLI generates:
```
project-name/
├── Cargo.toml          # Host workspace configuration
├── rust-toolchain.toml # Rust toolchain specification
├── .gitignore         # Git ignore file
├── src/
│   └── main.rs        # Host application entry point
└── guest/
    ├── Cargo.toml     # Guest program configuration
    └── src/
        ├── lib.rs     # Guest provable functions
        └── main.rs    # Guest entry point
```

## Configuration
- Uses `rust-toolchain.toml` for consistent Rust version across builds
- Includes optimized release profiles for performance
- Patches arkworks-algebra dependencies for compatibility

## Integration Points
- Integrates with `jolt-core` for core zkVM functionality
- Uses `tracer` component for RISC-V instruction tracing
- Leverages `jolt-sdk` for high-level APIs
- Works with `common` crate for shared utilities

This CLI serves as the main entry point for developers working with the Jolt zkVM, providing project scaffolding and toolchain management capabilities.