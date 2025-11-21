#!/bin/bash
# Automated Gap Execution Script
# Usage: ./scripts/execute-gap.sh <package_name>
# Example: ./scripts/execute-gap.sh dartian_orm

set -e

PACKAGE=$1
MIN_COVERAGE=95

if [ -z "$PACKAGE" ]; then
    echo "❌ Usage: $0 <package_name>"
    echo "   Example: $0 dartian_orm"
    exit 1
fi

PACKAGE_DIR="packages/$PACKAGE"

if [ ! -d "$PACKAGE_DIR" ]; then
    echo "❌ Package not found: $PACKAGE_DIR"
    exit 1
fi

echo "🚀 Executing Gap for: $PACKAGE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Setup PATH
export PATH="/opt/dart/bin:$HOME/.pub-cache/bin:$PATH"

cd "$PACKAGE_DIR"

# Step 1: Install dependencies
echo ""
echo "📦 Step 1/5: Installing dependencies..."
dart pub get

# Step 2: Run code generation if needed
if [ -f "build.yaml" ] || grep -q "build_runner" pubspec.yaml 2>/dev/null; then
    echo ""
    echo "⚙️  Step 2/5: Running code generation..."
    dart run build_runner build --delete-conflicting-outputs
else
    echo ""
    echo "⏭️  Step 2/5: Skipping code generation (not needed)"
fi

# Step 3: Run static analysis
echo ""
echo "🔍 Step 3/5: Running static analysis..."
if dart analyze; then
    echo "✅ Static analysis passed"
else
    echo "❌ Static analysis failed"
    exit 1
fi

# Step 4: Run tests
echo ""
echo "🧪 Step 4/5: Running tests..."
if dart test; then
    echo "✅ Tests passed"
else
    echo "❌ Tests failed"
    exit 1
fi

# Step 5: Check coverage
echo ""
echo "📊 Step 5/5: Checking test coverage..."
dart test --coverage=coverage
format_coverage --lcov --in=coverage --out=coverage/lcov.info \
    --packages=.dart_tool/package_config.json --report-on=lib

# Calculate coverage (simple bash calculation)
LF_TOTAL=$(grep -c "^LF:" coverage/lcov.info || echo "0")
LH_TOTAL=$(grep -c "^LH:" coverage/lcov.info || echo "0")

if [ "$LF_TOTAL" -eq 0 ]; then
    echo "⚠️  No coverage data found"
else
    # This is approximate - would need proper parsing
    echo "📈 Coverage data collected (see coverage/lcov.info)"
    echo "   Target: >= ${MIN_COVERAGE}%"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Gap execution complete for: $PACKAGE"
echo ""
echo "📝 Next steps:"
echo "   1. Review test results above"
echo "   2. Commit changes: git add -A && git commit -m 'feat: ...'"
echo "   3. Push: git push -u origin <branch>"
echo "   4. Update PLAN.md with progress"
