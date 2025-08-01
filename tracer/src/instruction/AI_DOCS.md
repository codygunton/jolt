# RISC-V Instruction Implementation Component

## Overview

The instruction component implements a comprehensive RISC-V instruction set architecture (ISA) emulator for the Jolt tracer. It provides concrete implementations for all RISC-V base instructions (RV32I/RV64I), multiplication/division extensions (RV32M/RV64M), atomic extensions (RV32A/RV64A), virtual instructions, and custom cryptographic extensions (SHA256).

## Architecture

### Core Traits and Enums

#### `RISCVInstruction`
The fundamental trait that all RISC-V instructions must implement:
- **`MASK`** and **`MATCH`**: Bit patterns for instruction decoding
- **`Format`**: Associated instruction format type
- **`RAMAccess`**: Associated memory access type
- **`execute(cpu, ram_access)`**: Core execution logic
- **`new(word, address, validate)`**: Instruction construction from binary
- **`random(rng)`**: Random instruction generation for testing

#### `RISCVTrace`
Extension trait for execution tracing:
- **`trace(cpu, trace_vec)`**: Captures complete execution state before/after instruction

#### `VirtualInstructionSequence`
For instructions that expand to multiple operations:
- **`virtual_sequence()`**: Returns sequence of constituent instructions

#### `RV32IMInstruction` Enum
Unified enum containing all supported instructions, with automatic serialization support and instruction decoding via `decode(instr, address)`.

### Instruction Categories

#### Base Integer Instructions (RV32I/RV64I)
**Arithmetic & Logic**: ADD, ADDI, SUB, AND, ANDI, OR, ORI, XOR, XORI, SLT, SLTI, SLTU, SLTIU
**Shifts**: SLL, SLLI, SRL, SRLI, SRA, SRAI, SLLW, SRLW, SRAW, SLLIW, SRLIW, SRAIW
**Loads**: LB, LBU, LH, LHU, LW, LWU, LD
**Stores**: SB, SH, SW, SD
**Branches**: BEQ, BNE, BLT, BGE, BLTU, BGEU
**Jumps**: JAL, JALR
**Upper Immediates**: LUI, AUIPC
**System**: ECALL, FENCE
**64-bit Extensions**: ADDIW, ADDW, SUBW

#### Multiplication/Division Extension (RV32M/RV64M)
**Multiplication**: MUL, MULH, MULHSU, MULHU, MULW
**Division**: DIV, DIVU, DIVW, DIVUW, REM, REMU, REMW, REMUW

#### Atomic Extension (RV32A/RV64A)
**Load-Reserved/Store-Conditional**: LRW, LRD, SCW, SCD
**Atomic Memory Operations**: AMOSWAP*, AMOADD*, AMOAND*, AMOOR*, AMOXOR*, AMOMIN*, AMOMAX*, AMOMINU*, AMOMAXU* (32-bit and 64-bit variants)

#### Virtual Instructions
Custom instructions for VM operations:
- **Assertions**: VirtualAssertEQ, VirtualAssertLTE, VirtualAssertHalfwordAlignment, VirtualAssertValidDiv0, VirtualAssertValidSignedRemainder, VirtualAssertValidUnsignedRemainder
- **Data Movement**: VirtualMove, VirtualMovsign, VirtualAdvice
- **Arithmetic**: VirtualMULI, VirtualPow2, VirtualPow2I, VirtualROTRI
- **Bitwise**: VirtualShiftRightBitmask, VirtualShiftRightBitmaskI, VirtualSRA, VirtualSRAI, VirtualSRL, VirtualSRLI

#### Custom Cryptographic Extensions
**SHA256**: SHA256 (compression), SHA256INIT (initialization)

### Memory Access System

#### `RAMAccess` Enum
Unified memory access representation:
- **`Read(RAMRead)`**: Memory read with address and value
- **`Write(RAMWrite)`**: Memory write with address, pre-value, post-value
- **`Atomic(RAMAtomic)`**: Atomic operation combining read and write
- **`NoOp`**: No memory access

### Instruction Execution Pipeline

#### `RISCVCycle<T>`
Complete execution state for an instruction:
```rust
pub struct RISCVCycle<T: RISCVInstruction> {
    pub instruction: T,
    pub register_state: <T::Format as InstructionFormat>::RegisterState,
    pub ram_access: T::RAMAccess,
}
```

#### Execution Flow
1. **Pre-execution**: Capture source register values
2. **Execution**: Perform instruction-specific computation
3. **Post-execution**: Capture destination register values and memory effects
4. **Tracing**: Optionally record complete execution state

## Key Features

### Comprehensive ISA Support
- Full RV32I/RV64I base instruction set
- RV32M/RV64M multiplication and division extensions
- RV32A/RV64A atomic operations
- Custom virtual instructions for VM operations
- SHA256 cryptographic extension

### Instruction Decoding
The `decode()` function implements complete RISC-V instruction decoding:
- Opcode-based primary dispatch
- funct3/funct7 field secondary dispatch
- Validation of instruction bit patterns
- Support for all implemented instruction formats

### Memory Access Abstraction
Unified memory access interface supporting:
- Simple reads and writes
- Atomic operations with acquire/release semantics
- Memory ordering constraints
- Address calculation and validation

### Register State Management
Comprehensive register tracking:
- Pre/post execution state capture
- 32-bit and 64-bit register value handling
- Source and destination register identification
- Sign extension and normalization

### Testing Infrastructure
Built-in testing support:
- Random instruction generation
- Randomized register states
- Deterministic testing with seeded RNGs
- Property-based testing capabilities

### Serialization Support
Full persistence via serde:
- JSON and binary serialization
- Cross-platform compatibility
- Execution trace storage and replay

## Instruction Implementation Pattern

Each instruction follows a consistent implementation pattern using the `declare_riscv_instr!` macro:

```rust
declare_riscv_instr!(
    name   = ADD,           // Instruction name
    mask   = 0xfe00707f,    // Instruction mask
    match  = 0x00000033,    // Instruction match pattern  
    format = FormatR,       // Instruction format
    ram    = ()             // RAM access type
);

impl ADD {
    fn exec(&self, cpu: &mut Cpu, ram_access: &mut <ADD as RISCVInstruction>::RAMAccess) {
        // Instruction-specific execution logic
        cpu.x[self.operands.rd] = 
            cpu.sign_extend(cpu.x[self.operands.rs1].wrapping_add(cpu.x[self.operands.rs2]));
    }
}

impl RISCVTrace for ADD {} // Enable tracing
```

## Virtual Instruction Sequences

Some instructions expand to multiple primitive operations:
- **Virtual instructions**: Assert operations, specialized arithmetic
- **Complex operations**: Multi-step computations
- **Emulation support**: Instructions not directly supported by hardware

## Integration Points

The instruction component integrates with:
- **CPU Emulator** (`crate::emulator::cpu::Cpu`): Register and memory access
- **Instruction Formats** (`format` module): Operand parsing and state tracking
- **Tracer Core**: Execution trace generation and analysis
- **Testing Framework**: Random instruction generation and validation

## Usage Examples

### Basic Instruction Execution
```rust
// Decode instruction from binary
let instr = RV32IMInstruction::decode(0x00208033, 0x1000)?; // ADD x0, x1, x2

// Execute with tracing
let mut trace = Vec::new();
instr.trace(&mut cpu, Some(&mut trace));

// Access execution results
let cycle = &trace[0];
let (rd_idx, old_val, new_val) = cycle.rd_write();
let ram_access = cycle.ram_access();
```

### Memory Operations
```rust
// Load instruction with memory access
let load_instr = RV32IMInstruction::decode(0x00012083, 0x1004)?; // LW x1, 0(x2)
load_instr.trace(&mut cpu, Some(&mut trace));

// Check memory access
match trace.last().unwrap().ram_access() {
    RAMAccess::Read(read) => println!("Read {} from {}", read.value, read.address),
    _ => unreachable!(),
}
```

### Virtual Instruction Sequences
```rust
// Virtual instruction that expands to multiple operations
if let RV32IMInstruction::VirtualMULI(instr) = decoded_instr {
    let sequence = instr.virtual_sequence();
    for sub_instr in sequence {
        sub_instr.execute(&mut cpu);
    }
}
```

## Design Principles

1. **ISA Compliance**: Strict adherence to RISC-V specification
2. **Modularity**: Each instruction as independent, testable unit
3. **Tracing**: Complete execution state capture for analysis
4. **Performance**: Efficient execution with minimal overhead
5. **Extensibility**: Easy addition of new instructions and extensions
6. **Testing**: Comprehensive random testing and validation
7. **Determinism**: Reproducible execution for debugging
8. **Memory Safety**: Safe memory access patterns and validation