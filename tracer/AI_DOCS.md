# Tracer Component - AI Documentation

## Overview
The `tracer` component is a RISC-V emulator specifically designed for the Jolt zero-knowledge virtual machine. It executes RISC-V programs and generates execution traces that are used by the Jolt proving system.

## Key Functionality

### Core Features
- **RISC-V Emulation**: Complete implementation of RV32IM instruction set
- **Execution Tracing**: Generates detailed traces of program execution for ZK proof generation
- **Memory Management**: Handles RISC-V memory layout with custom configurations
- **Checkpoint Support**: Provides lazy iteration and checkpointing capabilities for large traces

### Main Entry Points

#### `trace()` - src/lib.rs:70
Complete execution trace generation:
```rust
pub fn trace(
    elf_contents: Vec<u8>,
    inputs: &[u8], 
    memory_config: &MemoryConfig,
) -> (Vec<RV32IMCycle>, Memory, JoltDevice)
```
- Executes ELF binary to completion
- Returns full execution trace and final states

#### `trace_lazy()` - src/lib.rs:83
Lazy trace iteration:
```rust
pub fn trace_lazy(
    elf_contents: Vec<u8>,
    inputs: &[u8],
    memory_config: &MemoryConfig,
) -> LazyTraceIterator
```
- Returns iterator for memory-efficient trace processing

#### `trace_checkpoints()` - src/lib.rs:92
Checkpoint-based tracing:
```rust
pub fn trace_checkpoints(
    elf_contents: Vec<u8>,
    inputs: &[u8], 
    memory_config: &MemoryConfig,
    checkpoint_interval: usize,
) -> (Vec<std::iter::Take<LazyTraceIterator>>, JoltDevice)
```
- Creates periodic checkpoints for resumable execution

## Architecture

### Core Components

#### Emulator (`src/emulator/`)
- **CPU**: RISC-V processor implementation with register management
- **Memory**: Virtual memory system with MMU support
- **Terminal**: I/O handling for program interaction
- **ELF Analyzer**: ELF binary parsing and loading

#### Instructions (`src/instruction/`)
- **Individual Instructions**: Complete RV32IM instruction implementations
- **Formats**: Instruction format parsing (R, I, S, B, U, J types)
- **Virtual Instructions**: Jolt-specific virtual operations for optimization
- **Inline SHA256**: Specialized SHA256 instruction implementations

### Key Data Structures

#### `RV32IMCycle`
Represents a single instruction execution cycle containing:
- Instruction details and operands
- Register and memory state changes
- Control flow information

#### `LazyTraceIterator`
Memory-efficient iterator for processing large execution traces:
- Supports checkpointing and resumption
- Lazy evaluation to minimize memory usage

## Usage Patterns

### Basic Tracing
```rust
let (trace, memory, device) = trace(elf_contents, inputs, &memory_config);
// Process full execution trace
```

### Memory-Efficient Processing
```rust
let trace_iter = trace_lazy(elf_contents, inputs, &memory_config);
for cycle in trace_iter {
    // Process one instruction at a time
}
```

### Checkpoint-Based Execution
```rust
let (checkpoints, device) = trace_checkpoints(
    elf_contents, 
    inputs, 
    &memory_config, 
    1000 // checkpoint every 1000 cycles
);
```

## Integration Points

### With Jolt Core
- Provides execution traces consumed by Jolt's proving system
- Integrates with `JoltDevice` for system call handling
- Uses `MemoryConfig` from common configuration

### With Common Components
- Leverages shared constants (e.g., `RAM_START_ADDRESS`)
- Uses common device abstractions and memory configurations

## Development Notes

### Code Organization
- Forked from `takahirox/riscv-rust` with Jolt-specific modifications
- Instruction implementations follow consistent patterns
- Virtual instructions provide Jolt-specific optimizations

### Testing
- Individual instruction tests in `src/instruction/test.rs`
- Integration testing through example program execution

### Dependencies
- Core Rust ecosystem: `fnv`, `object`, `serde`
- Crypto: `ark-serialize` for serialization
- Utilities: `itertools`, `strum` for enhanced functionality

## Binary Target
- Executable: `jolt-emu` for standalone emulation
- Library: Core tracing functionality for integration