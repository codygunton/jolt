# Jolt Core Benchmarks

This directory contains performance benchmarks for critical components of the Jolt zkVM core library.

## Overview

The benchmarks measure performance of key cryptographic operations and polynomial computations that are central to Jolt's zero-knowledge proof system. These benchmarks help track performance regressions and optimize critical paths.

## Benchmark Files

### `binding.rs`
**Purpose**: Benchmarks polynomial variable binding operations for both dense and compact polynomial representations.

**Key Operations Tested**:
- `DensePolynomial::bind` - Sequential variable binding for dense polynomials
- `DensePolynomial::bind_parallel` - Parallel variable binding with configurable binding order
- `CompactPolynomial::bind_parallel` - Parallel binding for compact polynomials with u8 coefficients
- Batch binding operations for multiple polynomials

**Test Parameters**:
- Variable counts: 20, 22, 24, 26 (representing 2^n coefficients)
- Batch sizes: 4, 8, 16, 32 polynomials
- Binding orders: `LowToHigh`, `HighToLow`

### `commit.rs`
**Purpose**: Benchmarks polynomial commitment scheme performance for batch commitments.

**Commitment Schemes Tested**:
- **Zeromorph**: Modern polynomial commitment based on KZG
- **HyperKZG**: Hyperplonk-style KZG commitment scheme

**Test Setup**:
- SRS size: 1024 (2^10)
- 50 layers of polynomials
- 1024 coefficients per layer
- 90% of coefficients set to ones (sparse polynomial optimization)

### `compact_poly_bench.rs`
**Purpose**: Benchmarks evaluation performance for compact polynomials using u8 coefficients.

**Operations Tested**:
- Dot product evaluation method
- Inside-out evaluation method
- Variable counts: 16, 18, 20 (representing 2^n coefficients)

### `iai.rs`
**Purpose**: Instruction-level benchmarking using `iai-callgrind` for detailed performance profiling.

**Operations Measured**:
- Polynomial variable binding (`bound_poly_var_top`)
- Polynomial evaluation at specific points
- Uses 4096-coefficient polynomials for consistent measurement

### `poly_bench.rs`
**Purpose**: Comprehensive polynomial evaluation benchmarks comparing different evaluation strategies.

**Operations Tested**:
- Dot product evaluation method
- Inside-out evaluation method
- Variable counts: 12, 14, 16, 18, 20, 22, 24 (representing 2^n coefficients)

## Running Benchmarks

### Criterion Benchmarks
Most benchmarks use the Criterion framework for statistical measurement:

```bash
# Run all benchmarks
cargo bench

# Run specific benchmark
cargo bench --bench binding
cargo bench --bench commit
cargo bench --bench poly_bench
cargo bench --bench compact_poly_bench
```

### Instruction-level Analysis
For detailed performance profiling:

```bash
# Requires valgrind/callgrind
cargo bench --bench iai
```

## Performance Considerations

### Polynomial Representations
- **Dense polynomials**: Full coefficient storage, efficient for general operations
- **Compact polynomials**: u8 coefficient storage, optimized for sparse/binary polynomials

### Binding Order Impact
- `LowToHigh`: Binds variables from lowest index to highest
- `HighToLow`: Binds variables from highest index to lowest
- Order affects memory access patterns and parallelization efficiency

### Commitment Scheme Trade-offs
- **Zeromorph**: Generally faster for batch operations
- **HyperKZG**: Different security assumptions and proof sizes

## Key Dependencies

- `ark-bn254`: BN254 elliptic curve implementation
- `criterion`: Statistical benchmarking framework
- `iai-callgrind`: Instruction-level performance measurement
- `rayon`: Data parallelism for polynomial operations

## Optimization Areas

1. **Memory Access Patterns**: Polynomial operations are memory-intensive
2. **Parallelization**: Critical for large polynomial operations
3. **Field Arithmetic**: BN254 field operations are hot paths
4. **Sparse Polynomial Handling**: Compact representations for efficiency