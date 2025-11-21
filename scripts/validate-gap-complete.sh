#!/bin/bash
# Gap Completion Validation Checklist
# Usage: ./scripts/validate-gap-complete.sh <package_name> <gap_number>
# Example: ./scripts/validate-gap-complete.sh dartian_orm 2

set -e

PACKAGE=$1
GAP_NUM=$2

if [ -z "$PACKAGE" ] || [ -z "$GAP_NUM" ]; then
    echo "❌ Usage: $0 <package_name> <gap_number>"
    echo "   Example: $0 dartian_orm 2"
    exit 1
fi

PACKAGE_DIR="packages/$PACKAGE"

echo "📋 Gap #$GAP_NUM Completion Checklist for: $PACKAGE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Setup PATH
export PATH="/opt/dart/bin:$HOME/.pub-cache/bin:$PATH"

cd "$PACKAGE_DIR"

ERRORS=0

# Check 1: Tests pass
echo ""
echo "✓ Checking: Tests pass (dart test)..."
if dart test > /dev/null 2>&1; then
    echo "  ✅ PASSED"
else
    echo "  ❌ FAILED - Tests are failing"
    ERRORS=$((ERRORS + 1))
fi

# Check 2: Static analysis passes
echo ""
echo "✓ Checking: Static analysis (dart analyze)..."
ANALYZE_OUTPUT=$(dart analyze 2>&1)
ERROR_COUNT=$(echo "$ANALYZE_OUTPUT" | grep -c "^  error " || echo "0")

if [ "$ERROR_COUNT" -eq 0 ]; then
    echo "  ✅ PASSED (0 errors)"
else
    echo "  ❌ FAILED - $ERROR_COUNT errors found"
    ERRORS=$((ERRORS + 1))
fi

# Check 3: Code is formatted
echo ""
echo "✓ Checking: Code formatting (dart format)..."
FORMAT_OUTPUT=$(dart format --output=none --set-exit-if-changed lib/ 2>&1 || echo "CHANGED")
if [[ "$FORMAT_OUTPUT" != *"CHANGED"* ]]; then
    echo "  ✅ PASSED"
else
    echo "  ⚠️  WARNING - Code needs formatting (run: dart format .)"
fi

# Check 4: Dependencies are up to date
echo ""
echo "✓ Checking: Dependencies (dart pub get)..."
if dart pub get > /dev/null 2>&1; then
    echo "  ✅ PASSED"
else
    echo "  ❌ FAILED - Dependency issues"
    ERRORS=$((ERRORS + 1))
fi

# Check 5: Coverage exists
echo ""
echo "✓ Checking: Test coverage exists..."
if [ -f "coverage/lcov.info" ]; then
    echo "  ✅ PASSED (coverage/lcov.info exists)"
else
    echo "  ⚠️  WARNING - No coverage data (run: dart test --coverage=coverage)"
fi

# Check 6: PLAN.md mentions this gap
echo ""
echo "✓ Checking: PLAN.md updated..."
cd ../..
if grep -q "Gap #$GAP_NUM.*COMPLETO" PLAN.md; then
    echo "  ✅ PASSED - Gap #$GAP_NUM marked complete in PLAN.md"
elif grep -q "Gap #$GAP_NUM" PLAN.md; then
    echo "  ⚠️  WARNING - Gap #$GAP_NUM exists but not marked complete"
else
    echo "  ❌ FAILED - Gap #$GAP_NUM not found in PLAN.md"
    ERRORS=$((ERRORS + 1))
fi

# Check 7: Recent commit exists
echo ""
echo "✓ Checking: Recent commit for this gap..."
RECENT_COMMIT=$(git log -1 --grep="Gap #$GAP_NUM\|gap.*$GAP_NUM" --oneline || echo "")
if [ -n "$RECENT_COMMIT" ]; then
    echo "  ✅ PASSED - Found: $RECENT_COMMIT"
else
    echo "  ⚠️  WARNING - No recent commit mentions Gap #$GAP_NUM"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ]; then
    echo "✅ Gap #$GAP_NUM validation: PASSED"
    echo ""
    echo "📝 Ready to mark as complete! Next steps:"
    echo "   1. Update PLAN.md status to ✅ COMPLETO"
    echo "   2. Update progress percentage"
    echo "   3. Commit: git commit -m 'docs: Mark Gap #$GAP_NUM complete'"
    echo "   4. Push: git push"
    exit 0
else
    echo "❌ Gap #$GAP_NUM validation: FAILED ($ERRORS errors)"
    echo ""
    echo "🔧 Fix the errors above before marking complete"
    exit 1
fi
