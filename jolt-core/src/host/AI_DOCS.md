# Host Component

## Purpose
The host component manages guest program compilation, execution tracing, and analysis for the Jolt zkVM. It provides the build infrastructure and runtime environment for RISC-V guest programs that will be proven in zero-knowledge.

## Key Functionality

### Program Management (`mod.rs`)
- **Program struct**: Represents a guest program with configurable memory, stack, and I/O parameters
- **Build system**: Compiles Rust guest programs to RISC-V ELF binaries using custom toolchains
- **Instruction decoding**: Converts ELF binaries to sequences of RV32IM instructions
- **Virtual instruction expansion**: Expands complex instructions (DIV, MUL, memory ops, etc.) into virtual sequences
- **Execution tracing**: Generates execution traces of guest programs with given inputs

### Program Analysis (`analyze.rs`)
- **ProgramSummary**: Captures complete execution data including trace, bytecode, memory state, and I/O
- **Instruction analysis**: Counts and analyzes instruction frequency in execution traces
- **Serialization**: Supports saving/loading program summaries for offline analysis

### Toolchain Management (`toolchain.rs`)
- **Custom RISC-V toolchain**: Downloads and installs `riscv32im-jolt-zkvm-elf` toolchain
- **Standard toolchain**: Manages `riscv32im-unknown-none-elf` for no-std programs
- **Retry logic**: Robust download with exponential backoff
- **Automatic linking**: Links toolchains with rustup for seamless compilation

## Architecture

### Build Process
1. Install required RISC-V toolchains if missing
2. Generate custom linker script with memory/stack configuration
3. Compile guest program with optimization flags and custom link args
4. Output ELF binary to target directory

### Execution Flow
1. **decode()**: ELF → RV32IM instructions → expanded virtual sequences
2. **trace()**: Execute program with inputs → generate cycle-by-cycle trace
3. **trace_analyze()**: Combine decoding and tracing for complete analysis

### Memory Configuration
- Configurable memory size (default: from constants)
- Configurable stack size (default: from constants) 
- Configurable max input/output sizes
- Custom linker script generation for memory layout

## Dependencies
- **tracer**: Instruction decoding and execution tracing
- **common**: Shared constants and device definitions
- **field**: Jolt field trait for analysis
- **reqwest**: HTTP client for toolchain downloads
- **tokio**: Async runtime for downloads
- **rayon**: Parallel processing for instruction expansion

## Usage Patterns
```rust
// Create and configure program
let mut program = Program::new("guest_program");
program.set_memory_size(1024 * 1024);
program.set_func("main");

// Generate execution trace
let (trace, memory, device) = program.trace(&input_bytes);

// Analyze program characteristics  
let summary = program.trace_analyze::<F>(&input_bytes);
let instruction_counts = summary.analyze::<F>();
```

## Security Considerations
- Programs run in isolated RISC-V environment
- Memory bounds enforced through linker scripts
- No direct system access from guest programs
- ELF validation during loading

## Performance Notes
- Parallel instruction expansion using rayon
- Optimized compilation with `-C opt-level=z`
- Symbol stripping for smaller binaries
- Efficient binary serialization for program summaries