#!/bin/bash

# Dartian Framework - Lint Script
# Runs dart analyze on all packages

set -e

echo "🔍 Dartian Lint Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOTAL_PACKAGES=0
PASSED_PACKAGES=0
FAILED_PACKAGES=0
FAILED_PACKAGE_NAMES=()

for dir in packages/*/; do
  if [ -f "$dir/pubspec.yaml" ]; then
    TOTAL_PACKAGES=$((TOTAL_PACKAGES + 1))
    package_name=$(basename "$dir")

    echo ""
    echo "📦 Analyzing: $package_name"
    echo "─────────────────────────────────────────────────"

    cd "$dir"

    # Run dart analyze
    if dart analyze --fatal-infos --fatal-warnings; then
      echo "✅ $package_name: No issues found"
      PASSED_PACKAGES=$((PASSED_PACKAGES + 1))
    else
      echo "❌ $package_name: Issues found"
      FAILED_PACKAGES=$((FAILED_PACKAGES + 1))
      FAILED_PACKAGE_NAMES+=("$package_name")
    fi

    cd - > /dev/null
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Summary:"
echo "   Total packages:  $TOTAL_PACKAGES"
echo "   ✅ Passed:       $PASSED_PACKAGES"
echo "   ❌ Failed:       $FAILED_PACKAGES"

if [ $FAILED_PACKAGES -gt 0 ]; then
  echo ""
  echo "Failed packages:"
  for pkg in "${FAILED_PACKAGE_NAMES[@]}"; do
    echo "  - $pkg"
  done
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
else
  echo ""
  echo "🎉 All packages passed lint check!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
fi
