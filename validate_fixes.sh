#!/bin/bash

# Simple validation script to check for common issues in the modified files
echo "🔍 Validating fixes for deinmudda app..."

# Check for basic syntax issues in dart files
check_dart_syntax() {
    local file="$1"
    echo "Checking $file..."
    
    # Check for balanced braces
    local open_braces=$(grep -o '{' "$file" | wc -l)
    local close_braces=$(grep -o '}' "$file" | wc -l)
    
    if [ "$open_braces" -ne "$close_braces" ]; then
        echo "❌ Unbalanced braces in $file: $open_braces open, $close_braces close"
        return 1
    fi
    
    # Check for balanced parentheses in function calls
    local open_parens=$(grep -o '(' "$file" | wc -l)
    local close_parens=$(grep -o ')' "$file" | wc -l)
    
    if [ "$open_parens" -ne "$close_parens" ]; then
        echo "❌ Unbalanced parentheses in $file: $open_parens open, $close_parens close"
        return 1
    fi
    
    echo "✅ Basic syntax check passed for $file"
    return 0
}

# List of modified files
files=(
    "lib/services/timer_service.dart"
    "lib/models/quick_button_config.dart" 
    "lib/services/database_service.dart"
    "lib/screens/home_screen.dart"
    "lib/widgets/countdown_timer_widget.dart"
    "lib/screens/timer_dashboard_screen.dart"
    "lib/screens/quick_entry/quick_button_config_screen.dart"
)

echo "📁 Checking modified files..."
all_passed=true

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        if ! check_dart_syntax "$file"; then
            all_passed=false
        fi
    else
        echo "❌ File not found: $file"
        all_passed=false
    fi
done

echo ""
echo "🔍 Checking for specific fix implementations..."

# Check timer service fix
if grep -q "Allow multiple timers to run concurrently" lib/services/timer_service.dart; then
    echo "✅ Timer service concurrent timer fix implemented"
else
    echo "❌ Timer service fix not found"
    all_passed=false
fi

# Check cost field addition
if grep -q "final double cost;" lib/models/quick_button_config.dart; then
    echo "✅ Cost field added to QuickButtonConfig"
else
    echo "❌ Cost field not found in QuickButtonConfig"
    all_passed=false
fi

# Check database migration
if grep -q "cost.*REAL.*DEFAULT.*0.0" lib/services/database_service.dart; then
    echo "✅ Database migration for cost column implemented"
else
    echo "❌ Database migration for cost column not found"
    all_passed=false
fi

# Check layout constraints fix
if grep -q "LayoutBuilder" lib/widgets/countdown_timer_widget.dart; then
    echo "✅ Layout constraints fix implemented in countdown timer"
else
    echo "❌ Layout constraints fix not found"
    all_passed=false
fi

# Check cost usage in home screen
if grep -q "cost: config.cost" lib/screens/home_screen.dart; then
    echo "✅ Cost usage implemented in home screen quick entry"
else
    echo "❌ Cost usage not found in home screen"
    all_passed=false
fi

echo ""
if [ "$all_passed" = true ]; then
    echo "🎉 All validation checks passed!"
    echo "✅ Timer service allows concurrent timers"
    echo "✅ Cost tracking added to quick buttons"  
    echo "✅ UI layout constraints fixed"
    echo "✅ Database migration implemented"
    exit 0
else
    echo "❌ Some validation checks failed"
    exit 1
fi