# Background
This project is to resolve the issue that CKB C contracts and CKB Rust contracts uses different riscv toolchains.
For C contracts, it uses riscv64-unknown-linux-gnu.
For Rust contracts, it uses riscv64imac-unknown-none-elf.
The docker image for ckb-capsule only supports riscv64imac-unknown-none-elf.
The docker image for ckb-riscv-gnu-toolchain only supports riscv64-unknown-linux-gnu.

This docker images servers as a all in one solution that provides a dev environment for both C and Rust contracts.