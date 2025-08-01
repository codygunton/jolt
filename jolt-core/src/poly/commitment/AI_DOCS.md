# Polynomial Commitment Component

## Overview

This component implements polynomial commitment schemes for Jolt's zero-knowledge virtual machine (zkVM). Polynomial commitments are a fundamental cryptographic primitive that allows a prover to commit to a polynomial and later provide proofs that the polynomial evaluates to specific values at given points, without revealing the polynomial itself.

## Architecture

### Core Trait: `CommitmentScheme`

All commitment schemes implement this trait defined in `commitment_scheme.rs:12-79`:

```rust
pub trait CommitmentScheme: Clone + Sync + Send + 'static {
    type Field: JoltField + Sized;
    type ProverSetup: Clone + Sync + Send + Debug + CanonicalSerialize + CanonicalDeserialize;
    type VerifierSetup: Clone + Sync + Send + Debug + CanonicalSerialize + CanonicalDeserialize;
    type Commitment: Default + Debug + Sync + Send + PartialEq + CanonicalSerialize + CanonicalDeserialize + AppendToTranscript + Clone;
    type Proof: Sync + Send + CanonicalSerialize + CanonicalDeserialize + Clone + Debug;
    type BatchedProof: Sync + Send + CanonicalSerialize + CanonicalDeserialize;
    type OpeningProofHint: Sync + Send + Clone + Debug;
}
```

**Key Methods:**
- `setup_prover()` / `setup_verifier()`: Generate cryptographic parameters
- `commit()`: Create a commitment to a multilinear polynomial
- `prove()`: Generate opening proof for polynomial evaluation
- `verify()`: Verify opening proof against commitment

### Streaming Commitment Scheme

For memory-efficient commitments, the `StreamingCommitmentScheme` trait extends the base trait:

```rust
pub trait StreamingCommitmentScheme: CommitmentScheme {
    type State<'a>;
    fn initialize() -> Self::State<'_>;
    fn process() -> Self::State<'_>;
    fn finalize() -> Self::Commitment;
}
```

## Commitment Scheme Implementations

### 1. KZG (`kzg.rs`)
- **Based on**: Kate-Zaverucha-Goldberg polynomial commitments
- **Curve**: Uses pairing-friendly curves (Arkworks ecosystem)
- **Structure**: Structured Reference String (SRS) with G1/G2 powers
- **Efficiency**: Constant-size commitments and proofs
- **Use case**: Univariate polynomials

### 2. HyperKZG (`hyperkzg.rs`) 
- **Based on**: KZG extended to multilinear polynomials via Gemini transformation
- **Source**: Port from Microsoft Nova (Nova/src/provider/hyperkzg.rs)
- **Key Innovation**: Works directly with evaluation form (no FFTs needed)
- **Optimization**: Specialized for Spartan's polynomial IOP
- **Use case**: Multilinear polynomials in evaluation form

### 3. Zeromorph (`zeromorph.rs`)
- **Based on**: Zeromorph polynomial commitment scheme
- **Features**: Batched openings, multilinear polynomial support
- **Efficiency**: Optimized for multiple polynomial evaluations
- **Structure**: Extends KZG with additional G2 elements

### 4. Dory (`dory.rs`)
- **Based on**: Dory polynomial commitment scheme
- **Features**: Transparent setup (no trusted setup required)
- **Trade-offs**: Larger proof sizes but no ceremony needed

### 5. Hyrax (`hyrax.rs`)
- **Based on**: Hyrax polynomial commitment
- **Features**: Efficient for sparse polynomials
- **Use case**: When polynomials have many zero coefficients

### 6. Pedersen (`pedersen.rs`)
- **Based on**: Pedersen vector commitments
- **Features**: Simple, well-understood construction
- **Use case**: Basic polynomial commitments, often used in combination

### 7. BMMTV (`bmmtv.rs` + `bmmtv/` directory)
- **Based on**: Bulletproofs-style inner product arguments
- **Features**: No trusted setup, transparent
- **Structure**: Complex directory with multiple subprotocols:
  - `afgho.rs`: AFGHO polynomial commitment
  - `gipa.rs`: Generalized Inner Product Argument
  - `hyperbmmtv.rs`: Hyperplane variant
  - `inner_products.rs`: Core inner product operations
  - `mipp_k.rs`: Multi-inner product proof
  - `poly_commit.rs`: Main polynomial commitment interface

## Key Design Patterns

### 1. **Arkworks Integration**
All schemes use Arkworks cryptographic primitives:
- Pairing-friendly curves (`ark_ec::pairing::Pairing`)
- Field arithmetic (`ark_ff`)
- Serialization (`ark_serialize`)

### 2. **Parallel Processing**
Extensive use of Rayon for parallel computation:
- MSM (Multi-Scalar Multiplication) operations
- Polynomial evaluations
- Batch operations

### 3. **Generic Programming**
Heavy use of Rust generics and associated types:
- Field-agnostic implementations
- Curve-agnostic where possible
- Type-safe polynomial operations

### 4. **Memory Efficiency**
- Streaming interfaces for large polynomials
- Arc-wrapped shared data structures
- Efficient memory layout for coefficients

## File Structure

```
commitment/
├── mod.rs              # Module declarations
├── commitment_scheme.rs # Core trait definitions
├── kzg.rs             # KZG implementation
├── hyperkzg.rs        # HyperKZG for multilinear
├── zeromorph.rs       # Zeromorph scheme
├── dory.rs            # Dory transparent scheme
├── hyrax.rs           # Hyrax for sparse polynomials
├── pedersen.rs        # Pedersen commitments
├── bmmtv.rs           # BMMTV main module
├── bmmtv/             # BMMTV subprotocols
│   ├── afgho.rs
│   ├── gipa.rs
│   ├── hyperbmmtv.rs
│   ├── inner_products.rs
│   ├── mipp_k.rs
│   └── poly_commit.rs
└── mock.rs            # Test-only mock implementation
```

## Cryptographic Context

### Multilinear Polynomial Commitments
Jolt primarily uses multilinear polynomials, which are polynomials of degree at most 1 in each variable. The commitment schemes here provide:

1. **Succinct Commitments**: Constant or logarithmic size regardless of polynomial degree
2. **Efficient Opening Proofs**: Fast generation and verification of evaluation proofs  
3. **Batch Operations**: Commit to and open multiple polynomials efficiently
4. **Zero-Knowledge**: Commitments reveal nothing about the polynomial

### Integration with Jolt

These commitment schemes are used throughout Jolt for:
- **Instruction Lookups**: Committing to lookup table polynomials
- **Memory Checking**: Proving correct memory access patterns
- **R1CS Constraints**: Sparse constraint system proofs
- **Sumcheck Protocol**: Interactive proof components

### Security Assumptions

Different schemes rely on different cryptographic assumptions:
- **KZG/HyperKZG/Zeromorph**: Bilinear Diffie-Hellman assumptions in pairing groups
- **Dory**: Discrete logarithm assumptions, transparent setup
- **BMMTV**: Discrete logarithm, bulletproof-style security
- **Pedersen**: Discrete logarithm assumption

## Performance Characteristics

| Scheme | Commitment Size | Proof Size | Prover Time | Verifier Time | Setup |
|--------|----------------|------------|-------------|---------------|--------|
| KZG | O(1) | O(1) | O(n) | O(1) | Trusted |
| HyperKZG | O(1) | O(log n) | O(n) | O(log n) | Trusted |
| Zeromorph | O(1) | O(log n) | O(n) | O(log n) | Trusted |
| Dory | O(log n) | O(log n) | O(n log n) | O(log n) | Transparent |
| BMMTV | O(log n) | O(log n) | O(n log n) | O(log n) | Transparent |

Where n is the degree/size of the polynomial being committed to.

## Usage Patterns

1. **Setup Phase**: Generate proving/verifying keys using scheme-specific setup
2. **Commitment Phase**: Create commitments to polynomials using `commit()`
3. **Opening Phase**: Generate proofs for specific evaluations using `prove()`
4. **Verification Phase**: Verify proofs against commitments using `verify()`

The choice of commitment scheme depends on the specific requirements of proof size, verification time, and setup assumptions for the particular use case within Jolt's zkVM.