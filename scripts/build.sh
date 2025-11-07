#!/bin/bash

# Dartian Framework - Build Script
# Handles all build targets: exe, aot-snapshot, wasm

set -e

echo "🔨 Dartian Build System"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create build directory
mkdir -p build

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf build/*

# Get dependencies for all packages
echo ""
echo "📦 Installing dependencies..."
echo "─────────────────────────────────────────────────"

for dir in packages/*/; do
  if [ -f "$dir/pubspec.yaml" ]; then
    package_name=$(basename "$dir")
    echo "  → $package_name"
    cd "$dir"
    dart pub get > /dev/null 2>&1
    cd - > /dev/null
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 Building Dartian CLI..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Build AOT executable
echo ""
echo "🚀 Compiling AOT executable..."
dart compile exe packages/dartian_cli/bin/dartian.dart -o build/dartian

if [ -f build/dartian ]; then
  size=$(du -h build/dartian | cut -f1)
  echo "✅ AOT executable created: build/dartian ($size)"
  echo ""
  echo "Testing executable..."
  ./build/dartian version
else
  echo "❌ Failed to create AOT executable"
  exit 1
fi

# Build AOT snapshot
echo ""
echo "📸 Compiling AOT snapshot..."
dart compile aot-snapshot packages/dartian_cli/bin/dartian.dart -o build/dartian.aot

if [ -f build/dartian.aot ]; then
  size=$(du -h build/dartian.aot | cut -f1)
  echo "✅ AOT snapshot created: build/dartian.aot ($size)"
else
  echo "❌ Failed to create AOT snapshot"
  exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Build Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ls -lh build/
echo ""
echo "✅ Build completed successfully!"
echo ""
echo "💡 To run: ./build/dartian"
echo "💡 To build WASM: ./scripts/build-wasi.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
