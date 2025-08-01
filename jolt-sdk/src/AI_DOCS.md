# Jolt SDK

## Overview
The Jolt SDK provides a high-level interface for building and running programs on the Jolt zero-knowledge virtual machine (zkVM). It serves as the primary development toolkit for writing guest programs that can be proven using Jolt's RISC-V based zkVM.

## Core Components

### Library Structure (`lib.rs`)
- **Conditional compilation**: Uses `#![cfg_attr(not(feature = "host"), no_std)]` to support both host and guest environments
- **Re-exports**: Provides convenient access to `jolt_sdk_macros::provable` and `postcard` for serialization
- **Feature gates**: Conditionally includes modules based on feature flags (`host`, `sha256`, etc.)

### Key Modules

#### `provable` Macro
- Core macro from `jolt_sdk_macros` for marking functions as provable
- Enables functions to be executed within the zkVM and proven

#### `host_utils` (host feature only)
- Host-side utilities for interacting with the zkVM
- Only available when compiled with the "host" feature

#### `cycle_tracking`
- Utilities for tracking execution cycles within the zkVM
- Available in both host and guest environments

#### `alloc`
- Custom memory allocation utilities
- Provides zkVM-compatible memory management

#### `sha256` (sha256 feature only)
- SHA-256 hashing functionality optimized for the zkVM
- Conditionally compiled based on feature flags

### Features

#### `host`
- Enables host-side functionality including tracer, common utilities, and jolt-core
- Includes standard library support for postcard serialization
- Provides access to elliptic curve operations (ark-ec, ark-bn254)

#### `guest-std`
- Enables standard library support for guest programs
- Provides std support for both postcard and jolt-sdk-macros

#### `icicle`
- Enables GPU acceleration through the ICICLE library
- Depends on host feature and propagates to jolt-core

#### `sha256`
- Enables SHA-256 hashing functionality

## Dependencies

### Core Dependencies
- **postcard**: Efficient serialization library (no_std compatible)
- **jolt-sdk-macros**: Procedural macros for the SDK

### Optional Dependencies (host feature)
- **ark-ec**: Elliptic curve cryptography primitives
- **ark-bn254**: BN254 elliptic curve implementation
- **jolt-core**: Core zkVM implementation
- **tracer**: Execution tracing utilities
- **common**: Shared utilities across the Jolt ecosystem

## Usage Patterns

### Guest Programs
```rust
use jolt_sdk::provable;

#[provable]
fn my_computation(input: u32) -> u32 {
    // Your computation here
    input * 2
}
```

### Host Integration
```rust
// Host-side code for running and proving guest programs
use jolt_sdk::host_utils;
// Use host utilities to interact with the zkVM
```

## Memory Management
- Uses a custom `_HEAP_PTR` for compatibility
- Only active on host builds to avoid conflicts with guest allocator
- Provides zkVM-compatible allocation strategies through the `alloc` module

## Architecture Notes
- Designed for no_std environments by default
- Conditional compilation ensures appropriate code paths for host vs guest
- Modular design allows selective feature inclusion
- Integration with broader Jolt ecosystem through workspace dependencies