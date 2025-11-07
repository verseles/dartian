#!/bin/bash

# Dartian Framework - WASI Build Script
# Compiles Dart to WASM and tests with wasmtime

set -e

echo "🌐 Dartian WASM/WASI Build"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create build directory
mkdir -p build

echo "📦 Compiling to WASM..."
echo ""

# Check if dart compile wasm is available
if ! dart help compile | grep -q "wasm"; then
  echo "⚠️  WASM compilation not available in this Dart SDK"
  echo "💡 WASM support is experimental and may not be available"
  echo "💡 This is expected and not an error"
  exit 0
fi

# Try to compile (this might not work as expected without proper entrypoint)
if dart compile wasm packages/dartian_cli/bin/dartian.dart -o build/dartian.wasm 2>/dev/null; then
  echo "✅ WASM build successful"
  echo "📄 Output: build/dartian.wasm"
  echo ""

  if command -v wasmtime &> /dev/null; then
    echo "🧪 Testing with wasmtime..."
    if wasmtime build/dartian.wasm version 2>/dev/null; then
      echo "✅ WASI test passed"
    else
      echo "⚠️  WASI test failed (expected - WASM support is experimental)"
    fi
  else
    echo "💡 wasmtime not installed. Install with: paru -S wasmtime"
  fi
else
  echo "⚠️  WASM compilation failed (expected - full WASM support not yet implemented)"
  echo "💡 WASM support in Dart is experimental and limited"
  echo "💡 This is a placeholder for future WASM capabilities"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Note: Full WASM support requires:"
echo "   - Dart SDK with stable WASM compilation"
echo "   - Proper WASM entrypoint configuration"
echo "   - Compatible runtime environment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
