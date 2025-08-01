# Instruction Format Component

## Overview

The instruction format component implements RISC-V instruction parsing and register state management for the Jolt tracer. It provides a unified interface for handling different RISC-V instruction formats through traits and format-specific implementations.

## Architecture

### Core Traits

#### `InstructionFormat`
The main trait that all instruction formats must implement:
- **`parse(word: u32) -> Self`**: Decodes a 32-bit instruction word into format-specific fields
- **`capture_pre_execution_state()`**: Records register values before instruction execution
- **`capture_post_execution_state()`**: Records register values after instruction execution
- **`random(rng: &mut StdRng) -> Self`**: Generates random instruction instances for testing
- **`normalize() -> NormalizedOperands`**: Converts format-specific data to a common representation

#### `InstructionRegisterState`
Trait for register state tracking with serialization support:
- **`random(rng: &mut StdRng) -> Self`**: Generates random register states
- **`rs1_value()`, `rs2_value()`, `rd_values()`**: Accessor methods for register values

### Data Structures

#### `NormalizedOperands`
Unified representation of instruction operands:
```rust
pub struct NormalizedOperands {
    pub rs1: usize,    // Source register 1
    pub rs2: usize,    // Source register 2
    pub rd: usize,     // Destination register
    pub imm: i64,      // Immediate value
}
```

## Supported Instruction Formats

### R-Type Format (`format_r.rs`)
Register-to-register operations with three register operands.
- **Fields**: `rd`, `rs1`, `rs2`
- **Register State**: Tracks old/new `rd` values, current `rs1`/`rs2` values
- **Use Case**: Arithmetic and logical operations between registers

### I-Type Format (`format_i.rs`)
Instructions with immediate values.
- **Fields**: `rd`, `rs1`, `imm` (12-bit signed immediate)
- **Register State**: Tracks old/new `rd` values, current `rs1` value
- **Use Case**: Immediate arithmetic, loads, system calls

### B-Type Format (`format_b.rs`)
Branch instructions with conditional jumps.
- **Fields**: `rs1`, `rs2`, `imm` (12-bit signed branch offset)
- **Register State**: Tracks `rs1`/`rs2` values (no destination register)
- **Use Case**: Conditional branches comparing two registers

### S-Type Format (`format_s.rs`)
Store instructions for memory writes.
- **Fields**: `rs1` (base), `rs2` (source), `imm` (12-bit offset)
- **Register State**: Tracks source register values
- **Use Case**: Storing register values to memory

### U-Type Format (`format_u.rs`)
Upper immediate instructions.
- **Fields**: `rd`, `imm` (20-bit upper immediate)
- **Register State**: Tracks old/new `rd` values
- **Use Case**: Loading upper immediate values, PC-relative addressing

### J-Type Format (`format_j.rs`)
Jump instructions with large offsets.
- **Fields**: `rd`, `imm` (20-bit jump offset)
- **Register State**: Tracks old/new `rd` values
- **Use Case**: Unconditional jumps, function calls

### Load Format (`format_load.rs`)
Specialized format for memory load operations.
- **Fields**: `rd`, `rs1` (base), `imm` (12-bit offset)
- **Register State**: Tracks old/new `rd` values, base register value
- **Use Case**: Loading values from memory into registers

### Virtual Formats
Custom formats for virtual machine operations:
- **`format_virtual_halfword_alignment.rs`**: Halfword alignment operations
- **`format_virtual_right_shift_i.rs`**: Virtual immediate right shifts
- **`format_virtual_right_shift_r.rs`**: Virtual register right shifts

## Key Features

### Instruction Parsing
Each format implements RISC-V instruction decoding according to the ISA specification:
- Bit field extraction for register indices and immediate values
- Sign extension for signed immediates
- Format-specific field layouts

### Register State Tracking
Comprehensive register state management:
- Pre-execution state capture for source registers
- Post-execution state capture for destination registers
- Support for both 32-bit and 64-bit register values via `normalize_register_value()`

### Testing Support
Built-in randomization for comprehensive testing:
- Random instruction generation respecting format constraints
- Random register state generation for state transitions
- Deterministic testing with seeded random number generators

### Serialization
Full serialization support via Serde:
- JSON/binary serialization of instruction formats
- Register state persistence for debugging and analysis
- Cross-platform compatibility

## Utility Functions

### `normalize_register_value(value: i64, xlen: &Xlen) -> u64`
Normalizes register values based on architecture width:
- 32-bit: Sign-extends and masks to 32 bits
- 64-bit: Direct conversion to 64-bit unsigned

### `normalize_imm(imm: u64) -> i64`  
Converts unsigned immediate to signed 32-bit value with sign extension.

## Integration Points

The instruction format component integrates with:
- **CPU Emulator**: Register value capture during execution
- **Tracer**: Instruction decode and state tracking
- **Testing Framework**: Random instruction generation
- **Serialization**: Persistent storage of execution traces

## Usage Example

```rust
use format_r::{FormatR, RegisterStateFormatR};

// Parse a 32-bit instruction word
let instruction = FormatR::parse(0x00208033); // ADD x0, x1, x2

// Create register state tracker
let mut state = RegisterStateFormatR::default();

// Capture pre-execution state
instruction.capture_pre_execution_state(&mut state, &mut cpu);

// Execute instruction (external)
cpu.execute(&instruction);

// Capture post-execution state  
instruction.capture_post_execution_state(&mut state, &mut cpu);

// Normalize for common processing
let normalized = instruction.normalize();
```

## Design Principles

1. **Format Abstraction**: Common interface across all RISC-V instruction formats
2. **State Tracking**: Comprehensive register state capture for analysis
3. **Testing Support**: Built-in randomization for thorough testing
4. **Serialization**: Full persistence support for debugging
5. **Performance**: Efficient bit manipulation and minimal allocations
6. **Correctness**: Strict adherence to RISC-V ISA specification