#!/bin/bash
set -e

echo "Building jolt-emu if needed..."
if [ ! -f "target/release/jolt-emu" ]; then
  echo "Building jolt-emu binary..."
  cargo build --release -p tracer --bin jolt-emu
fi

# Ensure Docker image exists
./build_docker_image.sh

echo "Running RISCOF tests in Docker (with test execution enabled)..."
docker run --name riscof-jolt --rm \
  -v "$PWD/riscof/plugins/jolt:/dut/plugin" \
  -v "$PWD/target/release/jolt-emu:/dut/bin/dut-exe" \
  -v "$PWD/riscof/results:/riscof/riscof_work" \
  riscof:latest

echo "Tests complete. Check riscof/results/report.html for results."