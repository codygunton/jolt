# Polynomial Module (`jolt-core/src/poly`)

## Overview

The `poly` module implements various polynomial types and operations essential for the Jolt zero-knowledge virtual machine. This module provides multilinear polynomial arithmetic, evaluation algorithms, commitment schemes, and specialized polynomial types used throughout the Jolt protocol.

## Core Components

### 1. Multilinear Polynomials (`multilinear_polynomial.rs`)

**Purpose**: Central enum wrapper for different polynomial representations with optimized operations.

**Key Features**:
- `MultilinearPolynomial<F>` enum supporting multiple scalar types:
  - `LargeScalars(DensePolynomial<F>)` - Full field elements
  - `U[8|16|32|64]Scalars(CompactPolynomial<T, F>)` - Compact integer representations
  - `I64Scalars(CompactPolynomial<i64, F>)` - Signed integer scalars
  - `RLC(RLCPolynomial<F>)` - Random linear combination polynomials
  - `OneHot(OneHotPolynomial<F>)` - Sparse one-hot polynomials

**Key Operations**:
- `linear_combination()` - Efficiently combines polynomials with field coefficients
- `evaluate()` / `evaluate_dot_product()` - Polynomial evaluation at given points
- `bind()` / `bind_parallel()` - Variable binding for sumcheck protocols
- `dot_product()` - Inner product with coefficient vectors

**Memory Optimization**: Automatically selects most compact representation based on coefficient size.

### 2. Dense Polynomials (`dense_mlpoly.rs`)

**Purpose**: Core implementation of multilinear polynomials over finite fields.

**Key Features**:
- Stores evaluations over all Boolean hypercube vertices: `Z: Vec<F>`
- Variable binding operations for sumcheck protocols
- Optimized evaluation algorithms (serial vs parallel based on size)
- Memory-efficient binding with scratch space allocation

**Performance Optimizations**:
- `optimised_evaluate()` - Fast evaluation using bottom-up approach
- `bound_poly_var_top_zero_optimized()` - Parallel binding optimized for sparse polynomials
- `evaluate_at_chi_low_optimized()` - Low-memory dot product computation

### 3. Compact Polynomials (`compact_polynomial.rs`)

**Purpose**: Memory-efficient polynomial representation for small integer coefficients.

**Key Features**:
- Generic over scalar types `T: SmallScalar` (u8, u16, u32, u64, i64)
- Field element conversion only when needed
- Efficient field multiplication via lookup tables
- Binding operations with lazy field element conversion

### 4. Specialized Polynomial Types

#### Equality Polynomial (`eq_poly.rs`)
- **Purpose**: Implements `EQ(x,y)` multilinear extension
- **Usage**: Lagrange basis evaluation, sumcheck protocols
- **Algorithms**: Serial and parallel coefficient table computation
- **Optimization**: Cached intermediate results for repeated evaluations

#### One-Hot Polynomial (`one_hot_polynomial.rs`)
- **Purpose**: Sparse polynomial with single non-zero coefficient
- **Usage**: Memory-efficient representation of indicator functions
- **Operations**: Specialized evaluation and binding for sparse structure

#### Range Mask Polynomial (`range_mask_polynomial.rs`)
- **Purpose**: Encodes range constraints and validity checks
- **Usage**: Memory consistency checks, bytecode validation

#### Program I/O Polynomial (`program_io_polynomial.rs`)
- **Purpose**: Represents program input/output relationships
- **Usage**: Linking execution trace with I/O constraints

#### RLC Polynomial (`rlc_polynomial.rs`)
- **Purpose**: Random linear combination of multiple polynomials
- **Usage**: Batched polynomial operations, commitment aggregation

#### Prefix/Suffix Polynomials (`prefix_suffix.rs`)
- **Purpose**: Memory addressing and range operations
- **Usage**: Memory consistency proofs

### 5. Commitment Schemes (`commitment/`)

**Purpose**: Polynomial commitment protocols for zero-knowledge proofs.

#### Core Trait (`commitment_scheme.rs`)
```rust
pub trait CommitmentScheme {
    type Field: JoltField;
    type Commitment;
    type Proof;
    
    fn commit(poly: &MultilinearPolynomial<Self::Field>) -> Self::Commitment;
    fn prove(poly: &MultilinearPolynomial<Self::Field>, point: &[Self::Field]) -> Self::Proof;
    fn verify(commitment: &Self::Commitment, point: &[Self::Field], value: Self::Field, proof: &Self::Proof) -> bool;
}
```

#### Supported Schemes:
- **KZG** (`kzg.rs`) - Kate-Zaverucha-Goldberg commitments
- **Pedersen** (`pedersen.rs`) - Vector Pedersen commitments  
- **Hyrax** (`hyrax.rs`) - Square-root verification time
- **Dory** (`dory.rs`) - Logarithmic proof size and verification
- **Zeromorph** (`zeromorph.rs`) - Multilinear KZG variant
- **HyperKZG** (`hyperkzg.rs`) - Multilinear polynomial commitments
- **BMMTV** (`bmmtv/`) - Bulletproofs-style commitment with inner products

## Usage Patterns

### 1. Polynomial Creation
```rust
// From field elements
let poly = MultilinearPolynomial::from(coeffs: Vec<F>);

// From compact integers
let poly = MultilinearPolynomial::from(coeffs: Vec<u32>);

// Dense polynomial directly
let dense = DensePolynomial::new(evals);
```

### 2. Evaluation
```rust
let value = poly.evaluate(&point);  // Standard evaluation
let value = poly.evaluate_dot_product(&point);  // Via Lagrange basis
```

### 3. Linear Combinations
```rust
let result = MultilinearPolynomial::linear_combination(&polys, &coeffs);
```

### 4. Sumcheck Protocol Integration
```rust
poly.bind(challenge, BindingOrder::LowToHigh);
let evals = poly.sumcheck_evals(index, degree, order);
```

## Key Algorithms

### 1. Multilinear Extension Evaluation
- **Bottom-up evaluation**: O(2^n) → O(n) reduction through variable binding
- **Lagrange basis**: Direct dot product with equality polynomial evaluations
- **Parallel optimization**: Threading for large polynomials (>2^16 coefficients)

### 2. Variable Binding
- **Sequential binding**: Reduces polynomial dimension by 1 per challenge
- **Parallel binding**: Vectorized operations for large coefficient vectors
- **Memory management**: Scratch space reuse to minimize allocations

### 3. Commitment Operations
- **Homomorphic combination**: Linear combination of commitments matches linear combination of polynomials
- **Batch operations**: Amortized cost for multiple polynomial commitments
- **Opening proofs**: Efficient proofs of evaluation at specific points

## Integration with Jolt

The polynomial module serves several critical roles in Jolt:

1. **Memory Consistency**: Range mask and program I/O polynomials encode memory access patterns
2. **Lookup Tables**: Compact polynomials efficiently represent precomputed lookup table values  
3. **Sumcheck Protocol**: Binding and evaluation operations support interactive proofs
4. **Commitment Layer**: Various commitment schemes provide cryptographic binding to polynomial data
5. **Optimization**: Automatic selection of polynomial representation minimizes memory usage

## Performance Characteristics

- **Memory**: Compact representations reduce memory by 4-8x for small coefficients
- **Evaluation**: Optimized algorithms provide 2x speedup over naive approaches  
- **Binding**: Parallel binding scales with available CPU cores
- **Commitment**: Logarithmic proof sizes with schemes like Dory and HyperKZG

## Dependencies

- **Field Arithmetic**: `crate::field::JoltField` for finite field operations
- **Serialization**: `ark_serialize` for proof serialization
- **Parallelism**: `rayon` for parallel polynomial operations
- **Randomness**: `rand_core` for polynomial generation and testing