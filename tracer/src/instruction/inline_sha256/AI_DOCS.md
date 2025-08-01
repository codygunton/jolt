# Inline SHA256 Instructions

This component implements custom RISC-V instructions for SHA-256 compression function operations, providing efficient cryptographic hash computation within the Jolt zkVM tracer.

## Overview

The inline SHA256 component consists of two custom RISC-V instructions:
- `SHA256INIT`: Performs SHA-256 compression with standard initial values (BLOCK constants)
- `SHA256`: Performs SHA-256 compression with custom initial values loaded from memory

Both instructions implement the SHA-256 compression function as a sequence of virtual RISC-V instructions, allowing the zkVM to efficiently prove SHA-256 computations.

## Files

### `mod.rs`
Core implementation containing:
- **Constants**: SHA-256 initial hash values (`BLOCK`) and round constants (`K`)
- **`Sha256SequenceBuilder`**: Main builder class that generates sequences of RISC-V instructions to perform SHA-256 compression
- **Helper functions**: `execute_sha256_compression()` and `execute_sha256_compression_initial()` for direct computation

Key features:
- Supports both initial compression (using BLOCK constants) and custom IV compression
- Uses 32 virtual registers for efficient computation layout
- Implements all SHA-256 operations (Ch, Maj, Σ₀, Σ₁, σ₀, σ₁) using basic RISC-V instructions
- Handles message schedule expansion for rounds 16-63

### `sha256.rs`
Implements the `SHA256` instruction:
- **Opcode**: `0x0000000b` (custom-0 with funct7=0x00, funct3=0x0)
- **Format**: R-type instruction
- **Behavior**: 
  - Loads 16 input words from memory at `rs1`
  - Loads 8 initial state words from memory at `rs2`
  - Performs SHA-256 compression
  - Stores 8 output words back to memory at `rs2`

### `sha256init.rs`
Implements the `SHA256INIT` instruction:
- **Opcode**: `0x0000100b` (custom-0 with funct7=0x00, funct3=0x1)
- **Format**: R-type instruction  
- **Behavior**:
  - Loads 16 input words from memory at `rs1`
  - Uses standard SHA-256 initial values (BLOCK constants)
  - Performs SHA-256 compression
  - Stores 8 output words to memory at `rs2`

## Architecture

### Virtual Register Layout
The implementation uses 32 virtual registers with the following layout:
- **0-7**: Working variables A-H (rotated during rounds)
- **8-23**: Message schedule W[0..15]
- **24-27**: Temporary registers (t1, t2, scratch space)
- **28-31**: Initial E-H values when using custom IV

### SHA-256 Implementation Details

The compression function follows the standard SHA-256 algorithm:

1. **Message Schedule**: Expands 16 input words to 64 words using:
   - σ₀(x) = ROTR⁷(x) ⊕ ROTR¹⁸(x) ⊕ SHR³(x)
   - σ₁(x) = ROTR¹⁷(x) ⊕ ROTR¹⁹(x) ⊕ SHR¹⁰(x)

2. **Compression Function**: 64 rounds using:
   - Ch(E,F,G) = (E ∧ F) ⊕ (¬E ∧ G)
   - Maj(A,B,C) = (A ∧ B) ⊕ (A ∧ C) ⊕ (B ∧ C)
   - Σ₀(A) = ROTR²(A) ⊕ ROTR¹³(A) ⊕ ROTR²²(A)
   - Σ₁(E) = ROTR⁶(E) ⊕ ROTR¹¹(E) ⊕ ROTR²⁵(E)

3. **Final Addition**: Adds initial values to working variables

### Virtual Instruction Sequence

Both instructions implement the `VirtualInstructionSequence` trait, generating sequences of basic RISC-V instructions (ADD, XOR, AND, LW, SW, etc.) that perform the SHA-256 computation. This allows the zkVM to create proofs for SHA-256 operations using standard instruction lookups.

## Usage

These instructions are designed for use within the Jolt zkVM tracer to efficiently prove SHA-256 computations. They provide a high-level interface for SHA-256 operations while generating detailed instruction traces that can be proven using the zkVM's lookup table system.

Example usage pattern:
1. Store input data (16 words) in memory
2. For custom IV: store initial hash state (8 words) in memory
3. Execute `SHA256INIT` or `SHA256` instruction
4. Read result (8 words) from memory

The generated virtual instruction sequences ensure that all SHA-256 operations can be verified through the zkVM's constraint system.