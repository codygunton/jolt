# Future Development Plans - AI Documentation

## Component Overview
This directory contains documentation for planned future enhancements and research directions for the Jolt zkVM. These documents outline scalability improvements, performance optimizations, and advanced cryptographic features that will expand Jolt's capabilities beyond its current implementation.

## Directory Structure
```
future/
├── continuations.md              # Prover space control strategies
├── folding.md                   # Folding scheme integration plans
├── groth-16.md                  # Groth16 recursion for constant verification
├── improvements-since-release.md # Recent and ongoing improvements
├── on-chain-verifier.md         # EVM integration and gas optimization
├── opts.md                      # General optimization strategies
├── precompiles.md               # Custom instruction acceleration
├── proof-size-breakdown.md      # Analysis of proof component sizes
└── zk.md                        # Zero-knowledge property enhancements
```

## Core Development Themes

### Scalability Solutions
- **Continuations**: Breaking large computations into provable chunks to control memory usage
- **Streaming Prover**: Non-recursive space control techniques to eliminate memory bottlenecks
- **Folding Schemes**: Efficient proof aggregation using Nova/HyperNova style protocols

### Performance Optimizations
- **Proof Size Reduction**: Minimizing on-chain storage and verification costs
- **Precompile Integration**: Hardware acceleration for common operations
- **Gas Cost Optimization**: Reducing EVM verification costs from ~2M to ~280k gas

### Cryptographic Enhancements
- **Zero-Knowledge**: Adding privacy properties to current public proof system
- **Groth16 Composition**: Constant-size proofs regardless of computation length
- **Advanced Commitment Schemes**: Exploring alternatives to current HyperKZG usage

## Planned Architectures

### 1. Continuations System (`continuations.md:32-40`)
**Monolithic Chunking Approach:**
- Split execution traces into manageable chunks (N/M cycle segments)
- Prove each chunk independently with shared state transitions
- Linear verification cost scaling with chunk count M
- Configuration parameter: `ContinuationConfig` in main `Jolt` struct

**Long-term Streaming Prover:**
- Non-recursive space control leveraging sum-check properties
- Constant memory usage independent of trace length
- Maintains security without proof recursion
- Expected space: <10GB for 2^20 cycle chunks

### 2. Folding Integration (`folding.md:5-21`)
**Technical Implementation:**
- Nova with BN254 primary curve for native sum-check verification
- HyperNova techniques for polynomial evaluation claim folding
- Grumpkin scalar multiplications with CycleFold optimization
- Memory state consistency across shards via offline memory checking

**Performance Estimates:**
- 10GB space requirement for 2^20 cycle shards
- <13% prover time overhead from extra commitments
- Potential speedup for large shard sizes (2^23+) due to HyperKZG savings

### 3. Groth16 Recursion (`groth-16.md:29-45`)
**Two-Stage Composition:**
1. **Stage 1**: Jolt verifier as R1CS over Grumpkin scalar field
   - Few hundred thousand constraints due to native arithmetic
   - Spartan proof generation with Hyrax-over-Grumpkin commitment
2. **Stage 2**: Spartan verifier as R1CS over BN254 scalar field
   - ~6 million constraints for Groth16 input
   - Final constant-size proof for on-chain verification

## Implementation Strategies

### Memory Management
- **Space-Time Tradeoffs**: Configurable chunk sizes based on available RAM
- **Constraint Optimization**: 32-bit storage for small field elements in first Spartan round
- **Batched Operations**: Maximizing grand product proof batching for 2x size reduction

### Verification Optimization
- **Native vs Non-Native Arithmetic**: Careful field choice for constraint minimization
- **Batched Opening Proofs**: Combining multiple polynomial commitments
- **MLE Direct Evaluation**: Leveraging Lasso's SOS decomposability properties

### Engineering Considerations
- **Modular Design**: Incremental testing and adjustable components
- **Protocol Flexibility**: Support for future batching and commitment scheme changes
- **Backward Compatibility**: Maintaining existing API while adding advanced features

## Security Properties

### Cryptographic Assumptions
- **Non-Recursive Approach**: Unconditional security in Random Oracle Model
- **Folding Schemes**: Relies on discrete logarithm assumptions for elliptic curves
- **Groth16 Composition**: Bilinear Diffie-Hellman assumptions in pairing groups

### Attack Resistance
- **Space-Time Attacks**: Continuations prevent memory exhaustion DoS
- **Verification Soundness**: Constant verification cost prevents economic attacks
- **Privacy Preservation**: Groth16 composition enables zero-knowledge properties

## Development Timeline

### Short-term (Monolithic Chunking)
1. Add `ContinuationConfig` parameter to `Jolt` struct
2. Implement trace splitting with configurable chunk sizes
3. Handle memory state transitions between chunks
4. Optimize final chunk output verification

### Medium-term (Folding Integration)
1. Nova/HyperNova folding scheme implementation
2. Grumpkin curve integration for scalar operations
3. Memory consistency protocols across shards
4. Performance benchmarking and optimization

### Long-term (Full Streaming)
1. Non-recursive streaming prover algorithms
2. Advanced batching and commitment optimizations
3. Zero-knowledge enhancements via Groth16 composition
4. Production-ready precompile system

## Integration Points

### Core System Dependencies
- **Polynomial Commitments**: Enhanced batching with HyperKZG alternatives
- **Sum-check Protocol**: Streaming-compatible round implementations
- **Memory Checking**: Extended for cross-shard consistency verification
- **R1CS Constraints**: Uniformity optimizations for recursive circuits

### External Interfaces
- **EVM Integration**: Gas-optimized verifier contracts
- **WASM Support**: Browser-compatible proof generation
- **Hardware Acceleration**: GPU/FPGA optimization hooks
- **Language Frontends**: Enhanced compilation pipeline support

## Research Directions

### Theoretical Improvements
- **Post-Quantum Security**: Commitment scheme alternatives
- **Proof Composition**: Beyond Groth16 for future-proofing
- **Hardware Optimization**: ASIC/FPGA-friendly algorithms

### Practical Enhancements
- **Client-Side Proving**: Sub-1GB memory requirements for mobile devices
- **Verification Speed**: Further gas cost reductions below 280k
- **Developer Experience**: Simplified APIs and better debugging tools

This documentation provides a roadmap for Jolt's evolution from its current monolithic architecture to a highly scalable, efficient, and production-ready zkVM system.