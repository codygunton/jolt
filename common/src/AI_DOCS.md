# Jolt Common Library

## Overview
The `jolt-common` crate provides core shared functionality for the Jolt zero-knowledge virtual machine (ZKVM). This library contains essential constants, configuration structures, and the JoltDevice implementation that manages I/O operations and memory layout for RISC-V program execution within the Jolt ZKVM.

## Key Components

### Constants (`constants.rs`)
Defines fundamental system parameters:
- **XLEN**: 32-bit architecture word size
- **Register counts**: RISC-V (32) + Virtual (32) = 64 total registers  
- **Memory configuration**: Default sizes for RAM (10MB), stack (4KB), I/O buffers (4KB each)
- **Address space**: RAM starts at `0x80000000`
- **Memory layout**: `inputs || outputs || panic || termination || padding || RAM`

Key function:
- `virtual_register_index(index)`: Maps register indices to virtual register space

### Attributes (`attributes.rs`)
Provides attribute parsing for procedural macros with the `Attributes` struct containing:
- `wasm`: WebAssembly compilation flag
- `memory_size`, `stack_size`: Memory allocation parameters
- `max_input_size`, `max_output_size`, `max_trace_length`: Execution limits
- `guest_only`: Guest-only compilation mode

The `parse_attributes()` function processes macro attributes and applies defaults from constants.

### JoltDevice (`jolt_device.rs`)
Core I/O management component that acts as a "peripheral device" in the RISC-V emulator:

#### JoltDevice Structure
- `inputs`: Program input data (public)
- `outputs`: Program output data (public) 
- `panic`: Panic state flag
- `memory_layout`: Memory region mapping

#### Key Methods
- `load(address)`: Read from memory-mapped I/O regions
- `store(address, value)`: Write to output regions, handle panic/termination
- Address validation: `is_input()`, `is_output()`, `is_panic()`, `is_termination()`

#### MemoryLayout
Manages the complex memory mapping with regions for:
- **Input/Output**: Memory-mapped I/O at specific addresses
- **Stack**: Grows downward from I/O region  
- **Heap**: Grows upward from `RAM_START_ADDRESS`
- **Control**: Panic and termination bits
- **Alignment**: Word-aligned (4-byte) boundaries with power-of-2 padding

The layout calculation ensures proper alignment and prevents overflow while maintaining compatibility with the witness structure used in zero-knowledge proofs.

## Usage Context
This crate is fundamental to Jolt's ZKVM architecture, providing the bridge between high-level Rust programs and the underlying zero-knowledge proof system. The JoltDevice captures all I/O operations that become part of the public inputs to the proof, while the memory layout ensures consistent addressing between the emulator and proof generation.

## Dependencies
- `ark-serialize`: Canonical serialization for cryptographic types
- `serde`: General serialization support
- `syn`: Syntax tree manipulation (std feature only)

## Features
- `std`: Standard library support (enables attribute parsing)
- `no_std`: Embedded/constrained environment support