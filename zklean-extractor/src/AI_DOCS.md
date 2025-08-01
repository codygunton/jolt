# ZKLean Extractor

A tool for extracting Jolt ZK proof system components into Lean4-compatible format for formal verification.

## Purpose

The ZKLean Extractor is a code generation tool that extracts various components of the Jolt zero-knowledge proof system and converts them into a format suitable for the ZKLean library. This enables formal verification of ZK proofs in Lean4.

## Key Components

### Core Modules
- **R1CS Constraints** (`r1cs.rs`) - Extracts R1CS (Rank-1 Constraint System) constraints
- **Subtables** (`subtable.rs`) - Generates lookup table definitions 
- **Instructions** (`instruction.rs`) - Extracts RISC-V instruction implementations
- **Lookup Cases** (`modules/`) - Generates lookup table cases for verification

### Output Formats
- **Flat File Output**: Single file containing all generated Lean4 code
- **Package Output**: Complete Lean4 package with proper structure and dependencies

## Architecture

```
main.rs
├── ZkLeanR1CSConstraints::extract()
├── ZkLeanSubtables::extract() 
├── ZkLeanInstructions::extract()
└── ZkLeanLookupCases::extract()
```

The extractor uses a modular design where each component implements the `AsModule` trait, allowing clean separation of concerns and easy extension.

## Usage

### Command Line Arguments
- `-f, --file <FILE>`: Write output to file instead of stdout
- `-p, --package-path <PATH>`: Create a complete Lean4 package
- `-t, --template-dir <DIR>`: Use custom package template directory
- `-o, --overwrite`: Allow overwriting existing package directory

### Examples
```bash
# Generate flat file output
./zklean-extractor -f output.lean

# Generate complete Lean4 package
./zklean-extractor -p ./jolt-lean-package

# Use custom template
./zklean-extractor -p ./output -t ./my-template
```

## Dependencies

- **jolt-core**: Core Jolt proof system implementation
- **common**: Shared utilities and constants
- **ark-bn254**: Elliptic curve library for BN254
- **clap**: Command line argument parsing
- **build-fs-tree**: File system tree generation

## Technical Details

### Parameter Set
Currently configured for `RV32IParameterSet` targeting RISC-V 32-bit instruction set.

### MLE AST
Uses Multi-Linear Extension Abstract Syntax Tree with 16000 nodes for representing polynomial constraints.

### Output Generation
The tool generates Lean4 code that includes:
- Import statements for required dependencies
- Type definitions for constraints and lookup tables
- Formal specifications for instruction semantics
- Verification lemmas and proofs

## Integration

This extractor is part of the larger Jolt ecosystem and integrates with:
- Jolt Core proof system
- ZKLean formal verification library
- Lean4 theorem prover
- RISC-V instruction set architecture