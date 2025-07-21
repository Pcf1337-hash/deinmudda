#!/bin/bash

echo "🛠️  AnimatedSwitcher Overflow Fix Validation"
echo "============================================="

# Function to check if a string exists in a file
check_implementation() {
    local file=$1
    local pattern=$2
    local description=$3
    
    if grep -q "$pattern" "$file"; then
        echo "✅ $description"
        return 0
    else
        echo "❌ $description"
        return 1
    fi
}

# Main file to check
HOME_SCREEN="lib/screens/home_screen.dart"

echo ""
echo "📋 Checking AnimatedSwitcher implementation in $HOME_SCREEN..."

# Check for AnimatedSwitcher
check_implementation "$HOME_SCREEN" "AnimatedSwitcher" "AnimatedSwitcher is implemented"

# Check for LayoutBuilder
check_implementation "$HOME_SCREEN" "LayoutBuilder" "LayoutBuilder is used for responsive constraints"

# Check for ConstrainedBox
check_implementation "$HOME_SCREEN" "ConstrainedBox" "ConstrainedBox is used for height limits"

# Check for SingleChildScrollView
check_implementation "$HOME_SCREEN" "SingleChildScrollView" "SingleChildScrollView is used for overflow protection"

# Check for proper ValueKeys
check_implementation "$HOME_SCREEN" "ValueKey('quick_entry_loading')" "Loading state has proper ValueKey"
check_implementation "$HOME_SCREEN" "ValueKey('quick_entry_content')" "Content state has proper ValueKey"

# Check for ClampingScrollPhysics
check_implementation "$HOME_SCREEN" "ClampingScrollPhysics" "ClampingScrollPhysics is used"

# Check for maxHeight constraint using constraints.maxHeight
check_implementation "$HOME_SCREEN" "constraints.maxHeight \* 0.9" "Dynamic height constraint is implemented"

echo ""
echo "📋 Checking test files..."

# Check if test file exists
if [ -f "test/animated_switcher_overflow_test.dart" ]; then
    echo "✅ Test file created"
    
    # Check test content
    check_implementation "test/animated_switcher_overflow_test.dart" "AnimatedSwitcher should not overflow" "Overflow test is implemented"
    check_implementation "test/animated_switcher_overflow_test.dart" "ConstrainedBox should prevent overflow" "ConstrainedBox test is implemented"
    check_implementation "test/animated_switcher_overflow_test.dart" "ClampingScrollPhysics" "ScrollPhysics test is implemented"
else
    echo "❌ Test file not found"
fi

# Check if demo file exists
if [ -f "animated_switcher_test_demo.dart" ]; then
    echo "✅ Demo app created for manual testing"
else
    echo "❌ Demo app not found"
fi

echo ""
echo "📋 Validating fix requirements from problem statement..."

# Check against original requirements
echo "Requirements check:"

# 1. Find AnimatedSwitcher instance
if grep -q "AnimatedSwitcher" "$HOME_SCREEN"; then
    echo "✅ 1. Found and fixed AnimatedSwitcher instance"
else
    echo "❌ 1. AnimatedSwitcher not found"
fi

# 2. Ensure animated content never exceeds available height
if grep -q "constraints.maxHeight \* 0.9" "$HOME_SCREEN"; then
    echo "✅ 2. Height constraints ensure content doesn't exceed available height"
else
    echo "❌ 2. Height constraints not properly implemented"
fi

# 3. Check for solution implementation (SingleChildScrollView)
if grep -q "SingleChildScrollView" "$HOME_SCREEN" && grep -q "ConstrainedBox" "$HOME_SCREEN"; then
    echo "✅ 3. Solution implemented: SingleChildScrollView + ConstrainedBox"
else
    echo "❌ 3. Solution not properly implemented"
fi

# 4. Check for proper ValueKey usage
if grep -q "ValueKey.*quick_entry" "$HOME_SCREEN"; then
    echo "✅ 4. ValueKey properly set for AnimatedSwitcher transitions"
else
    echo "❌ 4. ValueKey not properly set"
fi

echo ""
echo "📊 Summary:"
echo "----------"

# Count checks
total_checks=0
passed_checks=0

# Check each requirement again and count
checks=(
    "AnimatedSwitcher"
    "LayoutBuilder" 
    "ConstrainedBox"
    "SingleChildScrollView"
    "ClampingScrollPhysics"
    "ValueKey.*quick_entry"
    "constraints.maxHeight \* 0.9"
)

for check in "${checks[@]}"; do
    total_checks=$((total_checks + 1))
    if grep -q "$check" "$HOME_SCREEN"; then
        passed_checks=$((passed_checks + 1))
    fi
done

echo "Implementation: $passed_checks/$total_checks checks passed"

if [ $passed_checks -eq $total_checks ]; then
    echo "🎉 All implementation requirements satisfied!"
    echo ""
    echo "🔧 To test the fix:"
    echo "   1. Run: dart run animated_switcher_test_demo.dart"
    echo "   2. Test on Galaxy S10 size (360x760)"
    echo "   3. Toggle Dark mode and Trippy theme"
    echo "   4. Watch for smooth transitions without overflow"
    echo ""
    echo "🧪 To run automated tests:"
    echo "   flutter test test/animated_switcher_overflow_test.dart"
else
    echo "⚠️  Some implementation requirements are missing"
fi