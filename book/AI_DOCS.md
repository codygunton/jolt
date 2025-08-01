# Jolt Documentation (mdBook)

## Component Overview
This component contains the Jolt project's documentation built with mdBook. It provides comprehensive documentation for the Jolt zero-knowledge virtual machine, including usage guides, architectural details, background theory, and development resources.

## Purpose
- **User Documentation**: Guides for installing, using, and integrating Jolt
- **Developer Documentation**: Technical details on architecture, implementation, and development workflows
- **Educational Content**: Background theory on zero-knowledge proofs, RISC-V, and cryptographic primitives
- **Community Resources**: Contributor guides and project roadmap

## Structure
- `book.toml`: mdBook configuration file
- `src/`: Source markdown files for the documentation
  - `SUMMARY.md`: Table of contents and navigation structure
  - Main sections:
    - **Usage**: Installation, quickstart, guests/hosts, troubleshooting
    - **How it works**: Architecture, instruction lookups, memory management
    - **Background**: Cryptographic theory (sumcheck, multilinear extensions, GKR)
    - **Development**: Setup guides and tools for contributors
    - **Future**: Roadmap and planned improvements
- `theme/`: Custom styling and assets

## Key Features
- Comprehensive RISC-V zkVM documentation
- Interactive examples and code snippets
- Mathematical notation support via KaTeX preprocessing
- Multi-section organization covering theory to practice
- Community contribution guidelines

## Dependencies
- mdBook for static site generation
- KaTeX preprocessor for mathematical notation
- Standard markdown with enhanced formatting

## Build Process
The documentation is built using mdBook, which converts the markdown source files into a static website. The KaTeX preprocessor handles mathematical expressions.

## Integration Points
- References code examples from `../examples/`
- Links to core implementation in `../jolt-core/`
- Connects with SDK documentation in `../jolt-sdk/`
- Provides development setup for the entire Jolt project

## Usage Context
This documentation serves as the primary resource for:
- New users learning to use Jolt
- Developers understanding the zkVM architecture
- Contributors working on the codebase
- Researchers studying zero-knowledge proof systems