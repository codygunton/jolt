# Jolt SDK Macros AI Documentation

## Overview
The Jolt SDK macros module provides procedural macros for simplifying the development of zero-knowledge programs using the Jolt zkVM. The primary macro `#[provable]` transforms regular Rust functions into complete zero-knowledge proof systems with host-side proving, verification, and execution capabilities.

## Module Structure

### Core Macro

#### `#[provable]` (lib.rs:17-37)
The main procedural macro that transforms annotated functions into comprehensive zkVM proof systems. When applied to a function, it generates multiple helper functions for the complete zero-knowledge workflow:

**Key Features:**
- Automatic code generation for proving, verification, and execution
- WASM support for browser-based verification
- Memory layout management with configurable parameters
- Cross-compilation support for guest and host environments

**Generated Functions:**
- `build_prover_{function_name}`: Creates a closure for proving operations
- `build_verifier_{function_name}`: Creates a closure for verification operations
- `prove_{function_name}`: Executes the proving process
- `compile_{function_name}`: Compiles the guest program
- `preprocess_prover_{function_name}`: Generates prover preprocessing data
- `preprocess_verifier_{function_name}`: Generates verifier preprocessing data
- `analyze_{function_name}`: Provides program analysis and metrics

### Implementation Details

#### `MacroBuilder` (lib.rs:39-699)
The core implementation struct that handles macro expansion and code generation.

**Key Components:**
- **Function Analysis** (lib.rs:639-654): Parses function signatures and extracts argument types
- **Memory Management**: Configurable memory layout with stack, input/output sizes
- **Cross-Platform Support**: Conditional compilation for guest, host, and WASM targets
- **Serialization**: Uses postcard for efficient data serialization between host and guest

#### Builder Methods

**Prover Functions** (lib.rs:103-134, 362-409):
- Generates closures that capture program and preprocessing data
- Handles input serialization and proof generation
- Returns both computation results and zero-knowledge proofs

**Verifier Functions** (lib.rs:136-182):
- Creates verification closures with preprocessing data
- Validates proofs against expected inputs/outputs
- Uses JoltDevice for I/O management

**Execution Functions** (lib.rs:184-196):
- Provides direct function execution without proof generation
- Useful for testing and development workflows

**Analysis Functions** (lib.rs:198-231):
- Generates program summaries and performance metrics
- Traces execution for optimization insights

**Preprocessing Functions** (lib.rs:258-360):
- Creates cryptographic preprocessing data for efficient proving/verification
- Handles both prover and verifier preprocessing separately
- Supports preprocessing data sharing between prover and verifier

#### Memory Layout Management (lib.rs:411-493)
Configures guest program memory with:
- Input/output buffer allocation
- Stack size configuration
- Memory safety with bounds checking
- Termination signal handling

#### Cross-Platform Features

**Guest Environment** (lib.rs:461-493):
- Assembly bootstrap code for RISC-V execution
- Custom panic handlers for zkVM environment
- Memory allocator configuration
- Direct memory I/O operations

**WASM Support** (lib.rs:556-698):
- Browser-compatible verification functions
- MessagePack serialization for web interop
- Lightweight verification without full proving capabilities

## Usage Context

This macro system enables developers to:
1. Write standard Rust functions with business logic
2. Automatically generate complete zkVM proof systems
3. Deploy to multiple environments (native, WASM, embedded)
4. Optimize memory usage and performance parameters

The generated code integrates with Jolt's host system for program compilation, tracing, and proof generation, while providing guest-side execution capabilities for the zkVM environment.

## Configuration Attributes

The `#[provable]` macro accepts various attributes for customization:
- `max_input_size`: Maximum input buffer size
- `max_output_size`: Maximum output buffer size  
- `stack_size`: Guest program stack allocation
- `memory_size`: Total guest memory allocation
- `max_trace_length`: Maximum execution trace length
- `guest_only`: Skip host-side function generation
- `wasm`: Enable WASM verification support

## Dependencies
- `proc_macro2`: Token stream manipulation
- `quote`: Code generation macros
- `syn`: Rust syntax parsing
- `postcard`: Efficient serialization
- Integration with `jolt-core` for zkVM functionality