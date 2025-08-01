# Instruction Component - AI Documentation

## Overview

The instruction component is the core of Jolt's zkVM that defines and implements all RISC-V instructions supported by the zero-knowledge virtual machine. It provides a unified interface for instruction execution, lookup table integration, and circuit constraint generation through a comprehensive trait system.

## Core Architecture

### 1. Trait System (`mod.rs`)

**Purpose**: Defines the foundational interfaces for instruction handling in Jolt's zkVM.

**Key Traits**:

#### `InstructionLookup<const WORD_SIZE: usize>`
- Maps instructions to their corresponding lookup tables
- Returns `Option<LookupTables<WORD_SIZE>>` for table-based operations
- None for instructions that don't require lookup tables

#### `LookupQuery<const WORD_SIZE: usize>`
- Converts instruction execution into lookup operations
- **Key Methods**:
  - `to_instruction_inputs()`: Returns (u64, i64) operand tuple
  - `to_lookup_operands()`: Converts inputs to lookup format (u64, u64)
  - `to_lookup_index()`: Creates interleaved bit index for sparse-dense operations
  - `to_lookup_output()`: Computes expected lookup result

#### `InstructionFlags`
- Maps instructions to boolean circuit flags
- Returns `[bool; NUM_CIRCUIT_FLAGS]` array for R1CS constraints

### 2. Circuit Flags System

**Purpose**: Boolean flags (`opflags`) used in Jolt's R1CS constraint system for instruction classification.

**Key Flags**:
- **Operand Flags**: `LeftOperandIsPC`, `RightOperandIsImm`, `LeftOperandIsRs1Value`, `RightOperandIsRs2Value`
- **Operation Flags**: `AddOperands`, `SubtractOperands`, `MultiplyOperands`
- **Instruction Type Flags**: `Load`, `Store`, `Jump`, `Branch`
- **Execution Flags**: `WriteLookupOutputToRD`, `InlineSequenceInstruction`, `Assert`
- **Virtual Sequence Flags**: `DoNotUpdateUnexpandedPC`, `Advice`
- **Special Flags**: `IsNoop`

### 3. Macro-Generated Implementations

**Purpose**: The `define_rv32im_trait_impls!` macro generates unified trait implementations for all supported instructions.

**Generated Implementations**:
- `InstructionLookup` for `RV32IMInstruction`
- `InstructionFlags` for `RV32IMInstruction`  
- `InstructionLookup` for `RV32IMCycle`
- `LookupQuery` for `RV32IMCycle`

## Supported Instructions

### 1. Standard RISC-V Instructions

#### Arithmetic Instructions
- **`ADD`**: Register-register addition with overflow
- **`ADDI`**: Register-immediate addition
- **`SUB`**: Register-register subtraction with overflow
- **`MUL`**: Lower 32/64 bits of multiplication
- **`MULHU`**: Upper bits of unsigned multiplication

#### Logical Instructions  
- **`AND`**, **`ANDI`**: Bitwise AND operations
- **`OR`**, **`ORI`**: Bitwise OR operations
- **`XOR`**, **`XORI`**: Bitwise XOR operations

#### Comparison Instructions
- **`SLT`**, **`SLTI`**: Signed less-than comparison
- **`SLTU`**, **`SLTIU`**: Unsigned less-than comparison

#### Control Flow Instructions
- **`BEQ`**, **`BNE`**: Branch on equal/not-equal
- **`BLT`**, **`BGE`**: Branch on less-than/greater-equal (signed)
- **`BLTU`**, **`BGEU`**: Branch on less-than/greater-equal (unsigned)
- **`JAL`**: Jump and link
- **`JALR`**: Jump and link register

#### Memory Instructions
- **`LW`**: Load word from memory
- **`SW`**: Store word to memory

#### System Instructions
- **`LUI`**: Load upper immediate
- **`AUIPC`**: Add upper immediate to PC
- **`ECALL`**: Environment call
- **`FENCE`**: Memory fence

### 2. Virtual Instructions

**Purpose**: Jolt-specific instructions for complex operations that require multiple lookup table entries.

#### Assertion Instructions
- **`VirtualAssertEQ`**: Assert two values are equal
- **`VirtualAssertLTE`**: Assert less-than-or-equal relationship
- **`VirtualAssertHalfwordAlignment`**: Assert 16-bit boundary alignment
- **`VirtualAssertValidDiv0`**: Assert valid division by zero handling
- **`VirtualAssertValidSignedRemainder`**: Assert valid signed remainder
- **`VirtualAssertValidUnsignedRemainder`**: Assert valid unsigned remainder

#### Data Movement Instructions
- **`VirtualMove`**: Move data between registers
- **`VirtualMovsign`**: Move with sign extension
- **`VirtualAdvice`**: Load advice/hint data

#### Arithmetic Instructions
- **`VirtualMULI`**: Virtual multiplication with immediate
- **`VirtualPow2`**: Power-of-two operations
- **`VirtualPow2I`**: Power-of-two with immediate

#### Shift Instructions
- **`VirtualSRA`**, **`VirtualSRAI`**: Arithmetic right shift
- **`VirtualSRL`**, **`VirtualSRLI`**: Logical right shift
- **`VirtualROTRI`**: Rotate right with immediate
- **`VirtualShiftRightBitmask`**, **`VirtualShiftRightBitmaskI`**: Shift with bitmask

## Implementation Patterns

### 1. Standard Instruction Pattern

Each instruction file (e.g., `add.rs`) implements:

```rust
impl<const WORD_SIZE: usize> InstructionLookup<WORD_SIZE> for ADD {
    fn lookup_table(&self) -> Option<LookupTables<WORD_SIZE>> {
        Some(RangeCheckTable.into())  // or appropriate table
    }
}

impl InstructionFlags for ADD {
    fn circuit_flags(&self) -> [bool; NUM_CIRCUIT_FLAGS] {
        let mut flags = [false; NUM_CIRCUIT_FLAGS];
        flags[CircuitFlags::LeftOperandIsRs1Value] = true;
        flags[CircuitFlags::RightOperandIsRs2Value] = true;
        flags[CircuitFlags::AddOperands] = true;
        flags[CircuitFlags::WriteLookupOutputToRD] = true;
        // Virtual sequence handling
        flags[CircuitFlags::InlineSequenceInstruction] = 
            self.virtual_sequence_remaining.is_some();
        flags[CircuitFlags::DoNotUpdateUnexpandedPC] = 
            self.virtual_sequence_remaining.unwrap_or(0) != 0;
        flags
    }
}

impl<const WORD_SIZE: usize> LookupQuery<WORD_SIZE> for RISCVCycle<ADD> {
    fn to_instruction_inputs(&self) -> (u64, i64) {
        match WORD_SIZE {
            32 => (self.register_state.rs1 as u32 as u64, 
                   self.register_state.rs2 as u32 as i64),
            64 => (self.register_state.rs1, self.register_state.rs2 as i64),
            _ => panic!("{WORD_SIZE}-bit word size is unsupported"),
        }
    }

    fn to_lookup_operands(&self) -> (u64, u64) {
        let (x, y) = self.to_instruction_inputs();
        (0, x + y as u64)  // Combined operand for range check
    }

    fn to_lookup_output(&self) -> u64 {
        let (x, y) = self.to_instruction_inputs();
        (x as u32).overflowing_add(y as u32).0.into()
    }
}
```

### 2. Virtual Instruction Pattern

Virtual instructions often have simpler patterns:

```rust
impl<const WORD_SIZE: usize> LookupQuery<WORD_SIZE> for RISCVCycle<VirtualAdvice> {
    fn to_instruction_inputs(&self) -> (u64, i64) {
        (0, 0)  // No instruction inputs
    }

    fn to_lookup_operands(&self) -> (u64, u64) {
        (0, self.instruction.advice as u32 as u64)  // Direct advice value
    }

    fn to_lookup_output(&self) -> u64 {
        self.instruction.advice as u32 as u64
    }
}
```

## Integration Points

### 1. Lookup Table System

Instructions integrate with Jolt's lookup table system through:
- **Range Check Tables**: For overflow detection and value validation
- **Specialized Tables**: Custom tables for complex operations (shifts, comparisons)
- **No Table**: Simple operations that don't require lookups

### 2. Circuit Constraint Generation

The flag system drives R1CS constraint generation:
- **Operand Selection**: Determines which values feed into constraints
- **Operation Type**: Specifies arithmetic operation for constraint equations
- **Control Flow**: Manages PC updates and branching logic
- **Virtual Sequences**: Handles multi-cycle instruction decomposition

### 3. Tracer Integration

Instructions work with the tracer system:
- `RISCVCycle<T>` wraps instruction data with execution state
- Register state access through `self.register_state`
- Program counter and memory state integration

## Word Size Support

The instruction system supports multiple word sizes:
- **8-bit**: Test mode only (`#[cfg(test)]`)
- **32-bit**: Standard RISC-V RV32IM
- **64-bit**: Extended RISC-V RV64IM

Word size affects:
- Operand truncation and sign extension
- Overflow behavior
- Lookup table indexing

## Testing Infrastructure

Each instruction includes comprehensive tests:
- **Materialize Entry Tests**: Verify lookup table entry generation
- **Flag Tests**: Validate circuit flag settings
- **Execution Tests**: Test instruction behavior across word sizes

## Performance Considerations

### 1. Lookup Optimization

- **Interleaved Indexing**: Efficient sparse-dense lookup indexing
- **Combined Operands**: Reduces lookup table size for arithmetic operations
- **Range Checks**: Optimized overflow detection

### 2. Virtual Sequences  

- **Inline Instructions**: Multi-cycle operations handled efficiently
- **PC Management**: Prevents unnecessary program counter updates
- **State Preservation**: Maintains execution context across virtual cycles

## Security Properties

- **Completeness**: All valid RISC-V instructions can be proven
- **Soundness**: Invalid instruction execution cannot produce valid proofs
- **Constraint Satisfaction**: Circuit flags ensure proper R1CS constraint generation
- **Lookup Integrity**: Table-based operations are cryptographically verified

## File Structure

```
instruction/
├── mod.rs                                    # Core traits and macro definitions
├── add.rs, addi.rs, ...                     # Standard RISC-V instructions
├── virtual_*.rs                             # Jolt virtual instructions  
└── test.rs                                  # Testing infrastructure
```

## Dependencies

- **tracer::instruction**: RISC-V instruction definitions and execution state
- **crate::zkvm::lookup_table**: Lookup table system integration
- **crate::utils**: Utility functions (bit interleaving, etc.)
- **strum**: Enum iteration and counting for circuit flags

## Usage Context

This component is automatically invoked during:
1. **Program Tracing**: Instructions are decoded and executed
2. **Constraint Generation**: Circuit flags drive R1CS constraint creation
3. **Lookup Generation**: Instruction operands are converted to lookup queries
4. **Proof Generation**: Lookup results are verified against expected outputs

The instruction system forms the foundation of Jolt's zkVM, providing the semantic bridge between RISC-V program execution and zero-knowledge proof generation.