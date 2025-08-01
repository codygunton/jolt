# jolt-core/src - AI Documentation

## Overview
This is the core source directory of Jolt, a zero-knowledge virtual machine (zkVM) implementation based on the lookup singularity principle. Jolt is built on Spartan and uses Arkworks as its foundation for cryptographic operations.

## Purpose
Jolt-core provides the fundamental components for:
- Zero-knowledge proof generation and verification for RISC-V program execution
- Polynomial commitment schemes and cryptographic protocols
- Virtual machine instruction implementation and lookup tables
- Memory and register state management
- Constraint system building (R1CS)

## Key Components

### Core Modules
- **zkvm/**: The main zero-knowledge virtual machine implementation
  - **instruction/**: RISC-V instruction implementations
  - **lookup_table/**: Precomputed lookup tables for efficient proving
  - **bytecode/**: Bytecode verification and constraint generation
  - **r1cs/**: Rank-1 constraint system implementation
  - **ram/**: Random access memory management
  - **registers/**: CPU register state handling

### Cryptographic Primitives
- **field/**: Finite field arithmetic operations
- **poly/**: Polynomial operations and multilinear extensions
- **msm/**: Multi-scalar multiplication operations
- **subprotocols/**: Core cryptographic subprotocols (sumcheck, etc.)

### Infrastructure
- **utils/**: Shared utilities, error handling, profiling
- **host/**: Host-side operations and toolchain management
- **benches/**: Performance benchmarking infrastructure

## Architecture
Jolt uses a lookup-based approach to zero-knowledge proving, where complex operations are decomposed into lookups in precomputed tables. This enables efficient proving of RISC-V program execution.

Key architectural elements:
1. **Instruction Decomposition**: RISC-V instructions are broken down into simpler operations
2. **Lookup Tables**: Precomputed tables for arithmetic and logical operations
3. **Constraint Generation**: R1CS constraints ensure correct execution
4. **Polynomial Commitments**: Various schemes (KZG, Dory, etc.) for cryptographic commitments

## Main Entry Points
- `lib.rs`: Main library interface exposing all modules
- `main.rs`: CLI tool for profiling and benchmarking

## Dependencies
- **arkworks**: Cryptographic primitives and elliptic curves
- **tracer**: Program execution tracing
- **common**: Shared utilities across the project

## Features
- Supports both CPU and GPU acceleration (ICICLE)
- Multiple polynomial commitment schemes
- Comprehensive RISC-V instruction support
- Memory-efficient constraint generation
- Parallel execution capabilities