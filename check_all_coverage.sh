#!/bin/bash
echo "=========================================="
echo "DARTIAN FRAMEWORK - COVERAGE REPORT"
echo "=========================================="
echo ""

for pkg in packages/*/; do
  pkg_name=$(basename "$pkg")
  if [ -f "$pkg/coverage/lcov.info" ]; then
    cd "$pkg"
    
    # Calculate coverage using Dart
    total_lines=$(grep -E "^LF:" coverage/lcov.info | awk -F: '{sum += $2} END {print sum}')
    covered_lines=$(grep -E "^LH:" coverage/lcov.info | awk -F: '{sum += $2} END {print sum}')
    
    if [ "$total_lines" -gt 0 ]; then
      pct=$(awk "BEGIN {printf \"%.1f\", ($covered_lines/$total_lines)*100}")
      
      if (( $(awk "BEGIN {print ($pct >= 95)}") )); then
        emoji="✅"
      elif (( $(awk "BEGIN {print ($pct >= 80)}") )); then
        emoji="🟡"
      else
        emoji="🔴"
      fi
      
      printf "%-25s %s %6s%% (%d/%d)\n" "$pkg_name" "$emoji" "$pct" "$covered_lines" "$total_lines"
    fi
    cd ../..
  else
    printf "%-25s ⚠️  No coverage data\n" "$pkg_name"
  fi
done

echo ""
echo "=========================================="
echo "Legend: ✅ >= 95%  🟡 >= 80%  🔴 < 80%"
echo "=========================================="
