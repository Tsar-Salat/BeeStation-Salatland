#!/bin/bash
# Build and launch script for BeeStation
# Cross-platform script that auto-detects BYOND installation

set -e

echo "Building BeeStation..."
cd "$(dirname "$0")/../.."

# Run the build
./tools/build/build dm

echo "Build completed. Launching DreamSeeker..."

# Launch DreamSeeker using the generic wrapper
./tools/build/dreamseeker-wrapper.sh beestation.dmb
