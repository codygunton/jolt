# RAM Component AI Documentation

## Overview

The RAM component in Jolt's zkVM implements cryptographic protocols for proving the correctness of memory operations in RISC-V program execution. It uses sumcheck protocols to verify that reads and writes to memory are performed correctly without revealing the actual memory contents.

## Architecture

### Core Components

1. **RamDag** (`mod.rs:101-404`) - Main orchestrator that manages RAM verification across multiple stages
2. **RAMPreprocessing** (`mod.rs:45-86`) - Preprocesses bytecode into word-aligned format for efficient verification
3. **Memory State Management** - Handles initial and final memory states with proper address remapping

### Key Modules

#### 1. Read/Write Checking (`read_write_checking.rs`)
- **Purpose**: Ensures memory consistency between reads and writes
- **Key Function**: Verifies that every read returns the value from the most recent write to that address
- **Implementation**: Uses sumcheck protocols with virtual polynomials

#### 2. Output Checking (`output_check.rs`)
- **Purpose**: Validates program outputs and final memory state
- **Components**:
  - `OutputSumcheck` - Verifies output correctness
  - `ValFinalSumcheck` - Validates final memory values

#### 3. Value Evaluation (`val_evaluation.rs`)
- **Purpose**: Evaluates memory values at specific points during execution
- **Key Function**: Ensures value consistency across memory operations

#### 4. RAF Evaluation (`raf_evaluation.rs`)
- **Purpose**: Handles Read-After-Write (RAF) consistency checks
- **Key Function**: Verifies that reads following writes return the correct updated values

#### 5. Virtual Address Handling (`ra_virtual.rs`)
- **Purpose**: Manages virtual memory address computations
- **Implementation**: `RASumcheck` protocol for address validation

#### 6. Boolean Constraints
- **Booleanity** (`booleanity.rs`) - Ensures binary constraint satisfaction
- **Hamming Booleanity** (`hamming_booleanity.rs`) - Boolean constraints with Hamming weight considerations
- **Hamming Weight** (`hamming_weight.rs`) - Validates Hamming weight computations

## Key Constants and Parameters

```rust
pub const NUM_RA_I_VARS: usize = 8;  // Number of RA variables

// Dynamic D parameter calculation
pub fn compute_d_parameter(K: usize) -> usize {
    let log_K = K.log_2();
    log_K.div_ceil(NUM_RA_I_VARS)
}
```

## Memory Layout and Address Remapping

The RAM component uses a sophisticated address remapping system:

```rust
pub fn remap_address(address: u64, memory_layout: &MemoryLayout) -> Option<u64> {
    if address == 0 {
        return None;  // No memory operation
    }
    if address >= memory_layout.input_start {
        Some((address - memory_layout.input_start) / 4 + 1)
    } else {
        panic!("Unexpected address {address}")
    }
}
```

## Sumcheck Protocol Stages

The RAM verification process is organized into multiple stages:

### Stage 2: Core Memory Operations
- **RAF Evaluation**: Validates read-after-write consistency
- **Read/Write Checking**: Ensures memory operation correctness
- **Output Checking**: Verifies program outputs

### Stage 3: Value Validation
- **Value Evaluation**: Validates memory values at specific points
- **Final Value Check**: Ensures final memory state correctness
- **Hamming Booleanity**: Boolean constraint validation

### Stage 4: Address and Boolean Verification
- **Hamming Weight**: Validates bit counting operations
- **Booleanity**: Ensures binary constraints
- **Virtual Address**: Validates address computations

## Usage Patterns

### Prover Construction
```rust
let ram_dag = RamDag::new_prover(&state_manager);
// Processes execution trace and builds initial/final memory states
```

### Verifier Construction
```rust
let ram_dag = RamDag::new_verifier(&state_manager);
// Sets up verification without access to execution trace
```

### Memory Preprocessing
```rust
let preprocessing = RAMPreprocessing::preprocess(memory_init);
// Converts byte-level memory initialization to word-aligned format
```

## Key Data Structures

### RAMPreprocessing
- `min_bytecode_address`: Starting address of bytecode segment
- `bytecode_words`: Word-aligned bytecode for efficient processing

### RamDag
- `K`: Memory size (power of 2)
- `T`: Number of execution steps
- `initial_memory_state`: Memory state at program start
- `final_memory_state`: Memory state after execution (prover only)

## Memory State Management

The component handles several memory regions:
1. **Bytecode**: Program instructions (read-only)
2. **Input Data**: Program inputs (read-only during execution)
3. **Output Data**: Program outputs (written during execution)
4. **DRAM**: Dynamic memory for program execution
5. **Control Flags**: Panic and termination indicators

## Integration Points

- **StateManager Integration**: Uses `StateManager` for proof data coordination
- **Commitment Scheme**: Integrates with polynomial commitment schemes
- **Transcript Protocol**: Implements Fiat-Shamir for non-interactive proofs
- **Parallel Processing**: Extensive use of Rayon for parallel computation

## Performance Considerations

- Word-aligned memory operations (4-byte boundaries)
- Parallel processing for large memory states
- Efficient address remapping to minimize proof size
- Optimized polynomial evaluations for sumcheck protocols

## Security Properties

- **Memory Consistency**: Guarantees that reads return correct values
- **Address Integrity**: Ensures proper address computations
- **Boolean Constraints**: Validates binary operations
- **Zero-Knowledge**: Hides actual memory contents while proving correctness