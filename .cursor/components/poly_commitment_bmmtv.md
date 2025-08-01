# BMMTV Polynomial Commitment Component

## Overview

The BMMTV polynomial commitment scheme is a sophisticated cryptographic component in the Jolt zero-knowledge proof system that provides an alternative to KZG commitments for polynomial operations. Located in `/src/poly/commitment/bmmtv/`, this module implements a layered approach to polynomial commitments with native support for both univariate and multilinear polynomials.

## Architecture

### Core Components

```
HyperBmmtv (multilinear polynomials)
    ↓ (reduces to)
UnivariatePolynomialCommitment 
    ↓ (transforms to)
BivariatePolynomialCommitment
    ↓ (uses)
AFGHO + MippK + KZG
    ↓ (built on)
GIPA + Inner Products
```

### File Structure

- **`poly_commit.rs`** - Main polynomial commitment implementation with bivariate and univariate schemes
- **`hyperbmmtv.rs`** - Multilinear polynomial support via Reduction of Knowledge (RoK)
- **`afgho.rs`** - Inner pairing product commitment scheme
- **`gipa.rs`** - General Inner Product Arguments (bulletproof-style recursive proofs)
- **`mipp_k.rs`** - Multiexponentiation with known field vector protocol
- **`inner_products.rs`** - Supporting inner product operations
- **`NOTICE.md`** - License and attribution information

## Key Algorithms

### Bivariate Polynomial Transformation
Transforms univariate polynomials f(x) into bivariate form F(X,Y) using degree splitting:
- Optimizes trade-offs between KZG and MIPP operations
- Uses skewed splitting for better concrete performance
- Degree parameters chosen as `(x_degree, y_degree)` to balance costs

### AFGHO Commitment Scheme
Simple pairing-based commitment: `commit(k, m) = ⟨m, k⟩_pairing`
- Uses Type-1 pairings extensively
- Forms building block for larger BMMTV construction
- Provides inner product commitments with pairing operations

### GIPA (General Inner Product Arguments)
Bulletproof-style recursive argument system:
- Reduces vector commitments by halving problem size at each step
- Achieves O(log n) proof size
- Uses Fiat-Shamir challenges for non-interactive proofs

### MippK Protocol
"Multiexponentiation with known field vector":
- Proves knowledge of committed values under structural constraints
- Demonstrates `U = A^b` for public vector b and committed A
- Combines GIPA with KZG proofs for commitment key verification

## Cryptographic Features

### Polynomial Support
- **Univariate**: Direct commitment and opening of single-variable polynomials
- **Bivariate**: Core transformation that enables efficient operations
- **Multilinear**: Via HyperBmmtv reduction to univariate case

### Security Properties
- **Binding**: Computationally binding under pairing assumptions
- **Hiding**: Commitments reveal no information about committed polynomials
- **Knowledge Soundness**: MippK ensures prover knows committed values
- **Zero-Knowledge**: Opening proofs leak no additional information

### Performance Characteristics
- **Proof Size**: O(log n) group elements via GIPA recursion
- **Verification**: Efficient through parallelization and batch operations
- **Setup**: Requires trusted SRS (Structured Reference String)
- **Trade-offs**: Optimized for medium-sized polynomials vs pure KZG

## Integration with Jolt

### Role in Zero-Knowledge Proofs
- Commits to execution traces as multilinear polynomials
- Supports lookup arguments and sum-check protocols
- Enables batching of multiple polynomial operations
- Provides polynomial evaluation proofs during constraint checking

### Advantages over KZG
- **Multilinear Native Support**: Direct handling via HyperBmmtv
- **Modularity**: Clean separation between polynomial types
- **Tunability**: Degree splitting allows use-case optimization
- **Batching Efficiency**: Parallel processing for multiple operations

## Implementation Details

### Dependencies
- **Arkworks**: Elliptic curve and pairing operations
- **Rayon**: Parallel processing for performance
- **Jolt Field**: Custom field arithmetic optimizations
- **KZG Integration**: Uses existing KZG implementation as building block

### Optimization Features
- Extensive parallelization using Rayon
- Memory-efficient polynomial representations
- Batched pairing operations
- Careful degree splitting for optimal performance

### Error Handling
- Comprehensive error types for commitment and verification failures
- Proper bounds checking for polynomial operations
- Secure random number generation with proper seeding

## Usage Patterns

### Typical Workflow
1. **Setup**: Generate structured reference string (SRS)
2. **Commit**: Create commitment to polynomial(s)
3. **Open**: Generate opening proof for evaluation point(s)
4. **Verify**: Check proof validity against commitment and claimed evaluation

### Integration Points
- Called by higher-level Jolt proof systems
- Interfaces with transcript system for Fiat-Shamir
- Coordinates with KZG commitments for hybrid approaches
- Supports batch operations for multiple polynomials

## License and Attribution

Forked from RIPP (Arkworks-rs) implementation, dual-licensed under Apache and MIT licenses. This version removes abstraction for optimization and simplifies trait bounds while updating to use Jolt's current KZG implementation.