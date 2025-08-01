# Jolt Tracer - AI Documentation

## Overview

The Jolt Tracer is a RISC-V emulator and execution tracer designed specifically for the Jolt zero-knowledge virtual machine (zkVM). It provides comprehensive tracing capabilities for RISC-V program execution, which are essential for zero-knowledge proof generation.

## Key Components

### Core Modules

- **`lib.rs`** - Main library entry point with core tracing functions
- **`main.rs`** - CLI binary for running the emulator standalone
- **`emulator/`** - RISC-V emulator implementation including CPU, memory management, and terminal I/O
- **`instruction/`** - Complete RISC-V instruction set implementation with support for RV32IM extensions

### Primary Functions

#### `trace()` - src/lib.rs:70
Executes a RISC-V program and generates complete execution trace along with final memory state.

**Parameters:**
- `elf_contents: Vec<u8>` - ELF binary to execute
- `inputs: &[u8]` - Program input data
- `memory_config: &MemoryConfig` - Memory configuration

**Returns:** `(Vec<RV32IMCycle>, Memory, JoltDevice)`
- Complete execution trace
- Final memory state
- Jolt device state

#### `trace_lazy()` - src/lib.rs:82
Returns a lazy iterator for trace generation, useful for memory-efficient processing of large traces.

#### `trace_checkpoints()` - src/lib.rs:92
Generates execution traces with periodic checkpoints for resumable trace generation.

### Architecture

```
tracer/
├── emulator/           # RISC-V emulator core
│   ├── cpu.rs         # CPU state and execution
│   ├── memory.rs      # Memory management
│   ├── mmu.rs         # Memory mapping unit
│   └── terminal.rs    # I/O terminal interface
├── instruction/       # RISC-V instruction implementations
│   ├── format/        # Instruction format handlers
│   └── inline_sha256/ # SHA-256 precompile support
└── lib.rs            # Main tracing API
```

## Usage Patterns

### Basic Tracing
```rust
use tracer::{trace, MemoryConfig};

let (execution_trace, final_memory, jolt_device) = trace(
    elf_contents,
    &inputs,
    &memory_config
);
```

### Lazy Tracing (Memory Efficient)
```rust
let lazy_iter = trace_lazy(elf_contents, &inputs, &memory_config);
for cycle in lazy_iter {
    // Process each cycle individually
}
```

### CLI Usage
```bash
jolt-emu program.elf --signature output.sig --trace true
```

## Key Features

- **Complete RISC-V RV32IM Support** - All base integer and multiplication instructions
- **Atomic Operations** - RV32A extension support
- **Virtual Instructions** - Custom Jolt-specific instructions for zkVM optimization
- **Memory Tracing** - Complete memory access tracking
- **Checkpoint Support** - Resumable execution from intermediate states
- **ELF Loading** - Direct execution of RISC-V ELF binaries
- **Signature Generation** - Memory signature output for verification

## Integration Points

### With Jolt Core
- Provides execution traces consumed by the Jolt prover
- Interfaces with `JoltDevice` for zkVM-specific operations
- Memory states used for zkVM memory checking

### With Common
- Uses shared memory configuration and constants
- Integrates with Jolt device abstractions

## Security & Verification

- **Deterministic Execution** - Ensures reproducible traces for proof generation
- **Memory Safety** - Proper bounds checking and memory isolation
- **ELF Validation** - Safe parsing and execution of untrusted binaries
- **State Integrity** - Maintains consistent CPU and memory state throughout execution

## Performance Characteristics

- **Lazy Evaluation** - Memory-efficient trace generation
- **Checkpoint Recovery** - Efficient resumption from intermediate states
- **Batch Processing** - Optimized for large program traces
- **Minimal Overhead** - Designed for integration with proof generation pipelines

## Testing & Validation

The tracer includes comprehensive test suites covering:
- Individual instruction correctness
- Full program execution
- Memory consistency
- Edge cases and error conditions
- Integration with zkVM pipeline

## Dependencies

Key external dependencies:
- `object` - ELF parsing and analysis
- `tracing` - Structured logging and instrumentation
- `itertools` - Iterator utilities for trace processing
- `serde` - Serialization for state persistence
- `clap` - CLI argument parsing