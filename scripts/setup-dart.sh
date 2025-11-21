#!/bin/bash
# Automated Dart SDK setup for restricted environments
# Usage: ./scripts/setup-dart.sh

set -e

echo "🔍 Checking Dart installation..."

# Check if Dart is already available
if command -v dart &> /dev/null; then
    echo "✅ Dart already installed: $(dart --version 2>&1 | head -1)"
    exit 0
fi

# Check for Dart in /opt/dart
if [ -f "/opt/dart/bin/dart" ]; then
    echo "✅ Dart found in /opt/dart"
    export PATH="/opt/dart/bin:$HOME/.pub-cache/bin:$PATH"
    echo "📝 Add to your shell: export PATH=\"/opt/dart/bin:\$HOME/.pub-cache/bin:\$PATH\""
    exit 0
fi

echo "📦 Installing Dart SDK..."

# Download latest stable Dart SDK
cd /tmp
wget -q https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip

# Extract and install
unzip -q dartsdk-linux-x64-release.zip
mv dart-sdk /opt/dart

# Verify installation
export PATH="/opt/dart/bin:$PATH"
dart --version

echo "✅ Dart SDK installed successfully!"
echo ""
echo "📝 Add to your ~/.bashrc or ~/.zshrc:"
echo "   export PATH=\"/opt/dart/bin:\$HOME/.pub-cache/bin:\$PATH\""
echo ""
echo "🔧 Installing coverage tool..."
dart pub global activate coverage

echo "✅ Setup complete!"
