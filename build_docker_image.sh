#!/bin/bash
# Build the RISCOF Docker image if it doesn't exist
set -e

echo "Checking for RISCOF Docker image..."
if ! docker images | grep -q "riscof.*latest"; then
  echo "Building RISCOF Docker image..."
  cd riscof && docker build -t riscof:latest .
  cd ..
  echo "Docker image built successfully!"
else
  echo "RISCOF Docker image already exists."
fi