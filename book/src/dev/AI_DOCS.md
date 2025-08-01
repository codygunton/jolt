# AI_DOCS.md - Development Documentation Component

## Overview
This component contains developer-focused documentation for the Jolt zkVM project. It serves as the entry point for developers who want to contribute to or work with the Jolt codebase.

## Purpose
The `book/src/dev/` directory provides essential documentation for:
- Setting up development environments
- Understanding development tools and workflows
- Getting started with Jolt development

## Files

### README.md
- **Purpose**: Main entry point for developer documentation
- **Content**: Links to installation guide and development tools documentation
- **Location**: `/home/cody/jolt/book/src/dev/README.md:1-5`

### install.md
- **Purpose**: Development environment setup instructions
- **Key Sections**:
  - Rust installation via rustup
  - RISC-V target installation for guest programs
  - mdBook installation for documentation building 
- **Location**: `/home/cody/jolt/book/src/dev/install.md:1-19`

### tools.md
- **Purpose**: Documentation of development tools and debugging techniques
- **Key Sections**:
  - Tracing with tokio-rs/tracing and Perfetto visualization
  - Objdump for debugging emulator/tracer issues
- **Location**: `/home/cody/jolt/book/src/dev/tools.md:1-14`

## Context in Jolt Project
This component is part of the Jolt zkVM documentation book, specifically focusing on developer onboarding and tooling. It complements other documentation sections like:
- Usage guides (`../usage/`)
- Architecture explanations (`../how/`)
- Background theory (`../background/`)

## Key Dependencies
- **Rust toolchain**: Core development language
- **RISC-V target**: `riscv32im-unknown-none-elf` for guest programs
- **mdBook**: Documentation generation tool with KaTeX support
- **Perfetto**: Chrome trace visualization tool
- **riscv64-unknown-elf-objdump**: Debugging tool for RISC-V binaries

## Development Workflow Integration
This documentation supports the standard Jolt development workflow:
1. Environment setup using install.md instructions
2. Code development and debugging using tools.md techniques
3. Performance analysis via tracing tools
4. Documentation updates via mdBook

## Maintenance Notes
- Keep installation instructions up-to-date with Rust ecosystem changes
- Update tracing examples when new performance optimization needs arise
- Ensure tool documentation reflects current debugging best practices