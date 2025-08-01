# AI Documentation: Jolt How It Works

## Component Overview
This directory contains comprehensive documentation explaining the internal architecture and implementation details of the Jolt zkVM. It serves as the technical reference for understanding how Jolt's four core components work together to create an efficient zero-knowledge virtual machine.

## Directory Structure
- `architecture.md` - High-level overview of Jolt's four core components and their interactions
- `bytecode.md` - Detailed explanation of bytecode decoding and preprocessing from ELF files
- `instruction_lookups.md` - Technical details on using Lasso lookup arguments for instruction execution
- `m-extension.md` - Documentation on RISC-V M-extension multiplication instructions
- `r1cs_constraints.md` - Explanation of R1CS constraints for fetch-execute loop coordination
- `read_write_memory.md` - Details on memory checking arguments for RAM and register operations
- `sparse-constraint-systems.md` - Technical documentation on sparse constraint system optimizations

## Key Concepts

### Jolt's Four Components Architecture
1. **Read-write memory** - Handles RAM and register operations using Spice memory checking
2. **R1CS constraints** - Manages program counter updates and inter-component consistency (≈60 constraints/cycle)
3. **Instruction lookups** - Executes instructions using Lasso lookup arguments with decomposability
4. **Bytecode** - Decodes and preprocesses guest program bytecode for offline memory checking

### Technical Foundations
- **Lasso Lookup Arguments**: Core primitive enabling efficient instruction execution with costs proportional to number of lookups rather than table size
- **Offline Memory Checking**: Foundational technique used for both read-only (Lasso) and read-write (Spice) memory operations
- **Decomposability Property**: Key requirement allowing complex instructions to be broken into chunks for subtable lookups
- **Spartan R1CS**: Optimized for highly-structured constraint systems with block-diagonal matrices

### Implementation Details
- Bytecode preprocessing converts ELF `.text` sections into `BytecodeRow` structs containing address, bitflags, registers (rd/rs1/rs2), and immediate values
- Memory checking arguments provide security guarantees for all memory operations without requiring expensive polynomial commitments to entire memory state
- Instruction execution leverages decomposability to break 32-bit operations into smaller chunks (typically 8-16 bits) for efficient lookup table queries

## Integration Points
This documentation layer connects to:
- **Core Implementation**: `jolt-core/src/zkvm/` modules implementing these architectural components
- **Tracer**: ELF processing and instruction decoding pipeline
- **Book Structure**: Part of broader educational materials explaining Jolt's design philosophy and technical innovations

## Development Context
These documents serve as the authoritative technical reference for contributors working on Jolt's core zkVM components, providing detailed explanations of cryptographic primitives, architectural decisions, and implementation strategies that make Jolt's performance characteristics possible.