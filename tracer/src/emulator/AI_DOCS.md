# RISC-V Emulator Component

## Overview
This component implements a complete RISC-V CPU emulator with support for RV32I and RV64I instruction sets. It provides cycle-accurate emulation capabilities with memory management, ELF program loading, and I/O terminal interfaces.

## Core Components

### Emulator (`mod.rs`)
- **Main emulator struct** that orchestrates all components
- **Program execution** with ELF binary support and symbol table loading
- **Test mode support** for riscv-tests with automatic pass/fail detection
- **State management** with save/restore capabilities
- **Memory configuration** with different capacities for test vs program modes

### CPU (`cpu.rs`) 
- **RISC-V processor implementation** supporting both 32-bit and 64-bit modes
- **Instruction execution** with cycle-by-cycle operation
- **Register management** including general-purpose and CSR registers
- **Privilege level handling** (User, Supervisor, Machine modes)
- **Exception and interrupt processing** with trap handling

### Memory Management Unit (`mmu.rs`)
- **Virtual memory management** with SV32/SV39 paging support
- **Physical memory addressing** with DRAM base mapping
- **Memory protection** and address translation
- **Peripheral device mapping** and access control
- **Jolt device integration** for specialized operations

### Memory (`memory.rs`)
- **Physical memory storage** with 64-bit word granularity
- **Byte, halfword, word, and doubleword access** methods
- **Efficient storage** using vector-based implementation
- **Memory initialization** with configurable capacity

### ELF Analyzer (`elf_analyzer.rs`)
- **ELF file parsing** for RISC-V binaries
- **Symbol table extraction** and virtual address mapping
- **Section header processing** for program data loading
- **Binary validation** and format verification

### Terminal Interface (`terminal.rs`, `default_terminal.rs`)
- **I/O abstraction** for emulator input/output operations
- **Buffer management** for stdin/stdout data transfer
- **Pluggable terminal implementations** via trait system
- **Default terminal** with basic functionality and dummy terminal for testing

## Key Features

### Instruction Set Support
- Complete RV32I base integer instruction set
- RV64I extensions for 64-bit operations
- Compressed instruction set (RVC) support
- Memory access instructions with proper alignment handling

### System Capabilities
- Virtual memory with page table management
- Privilege level enforcement and transitions
- CSR (Control and Status Register) access
- Timer and interrupt handling
- Syscall emulation support

### Testing Integration
- riscv-tests compatibility with automatic test detection
- Signature region support for compliance testing
- Tohost/fromhost communication protocol
- Test result reporting with pass/fail status

### Performance Features
- Cycle-accurate execution timing
- Configurable memory capacity based on use case
- Efficient memory representation with 64-bit granularity
- State save/restore for debugging and checkpointing

## Usage Patterns

### Basic Emulation
```rust
let mut emulator = Emulator::new(Box::new(DefaultTerminal::new()));
emulator.setup_program(elf_binary);
emulator.run_test(trace_enabled);
```

### Memory Access
```rust
let mmu = emulator.get_mut_cpu().get_mut_mmu();
let value = mmu.load_word(address);
mmu.store_byte(address, data);
```

### Symbol Resolution
```rust
let symbol_addr = emulator.get_address_of_symbol(&"main".to_string());
```

## Integration Points

### Jolt Integration
- **JoltDevice** interface for specialized zkVM operations
- **Memory configuration** alignment with Jolt requirements
- **Trace generation** for proof system integration

### Instruction Processing
- **RV32IMCycle** structure for trace collection
- **RV32IMInstruction** enum for instruction representation
- **Execution tracing** for verification and debugging

## Architecture Notes

### Memory Layout
- DRAM base at 0x80000000 following RISC-V conventions
- Test programs use smaller memory capacity (50MB)
- Full programs support up to 128MB memory space
- Memory-mapped I/O regions for peripheral access

### Privilege Modes
- Machine mode for bootloader and hypervisor code
- Supervisor mode for operating system kernel
- User mode for application programs
- Proper mode transitions with trap handling

### Address Translation
- SV32 for 32-bit virtual addressing (4KB pages)
- SV39 for 64-bit virtual addressing (4KB pages)
- Page table walking with proper permission checks
- TLB-like caching for translation efficiency