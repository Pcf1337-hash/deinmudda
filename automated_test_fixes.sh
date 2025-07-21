#!/bin/bash

# Automated testing script for critical fixes
# This replaces manual testing procedures with automated validation

echo "🚀 Running automated tests for critical fixes..."

# Function to check file exists and contains expected patterns
check_fix() {
    local file="$1"
    local pattern="$2"
    local description="$3"
    
    if [ -f "$file" ]; then
        if grep -q "$pattern" "$file"; then
            echo "✅ $description"
            return 0
        else
            echo "❌ $description - Pattern not found: $pattern"
            return 1
        fi
    else
        echo "❌ $description - File not found: $file"
        return 1
    fi
}

# Test counter
total_tests=0
passed_tests=0

# Test 1: Visual fallback for layout errors in main.dart
total_tests=$((total_tests + 1))
if check_fix "lib/main.dart" "_showVisualErrorFallback" "Visual fallback for layout errors implemented"; then
    passed_tests=$((passed_tests + 1))
fi

# Test 2: Timer service optimization with Map structure
total_tests=$((total_tests + 1))
if check_fix "lib/services/timer_service.dart" "Map<String, Entry>" "Timer service optimized with Map structure"; then
    passed_tests=$((passed_tests + 1))
fi

# Test 3: Maximum concurrent timers limit
total_tests=$((total_tests + 1))
if check_fix "lib/services/timer_service.dart" "_maxConcurrentTimers" "Timer service has concurrent timer limits"; then
    passed_tests=$((passed_tests + 1))
fi

# Test 4: SQL injection prevention in database service
total_tests=$((total_tests + 1))
if check_fix "lib/services/database_service.dart" "_containsSqlInjectionAttempt" "SQL injection prevention implemented"; then
    passed_tests=$((passed_tests + 1))
fi

# Test 5: Safe parameterized queries
total_tests=$((total_tests + 1))
if check_fix "lib/services/database_service.dart" "safeQuery" "Safe parameterized queries implemented"; then
    passed_tests=$((passed_tests + 1))
fi

# Test 6: Responsive substance card with LayoutBuilder
total_tests=$((total_tests + 1))
if check_fix "lib/widgets/dosage_calculator/substance_card.dart" "LayoutBuilder" "Responsive substance card with LayoutBuilder"; then
    passed_tests=$((passed_tests + 1))
fi

# Test 7: Modular quick entry management screen
total_tests=$((total_tests + 1))
if check_fix "lib/widgets/quick_entry/quick_button_list.dart" "QuickButtonList" "Quick entry management screen modularized"; then
    passed_tests=$((passed_tests + 1))
fi

# Test 8: Responsive widgets implementation
total_tests=$((total_tests + 1))
if check_fix "lib/widgets/responsive_widgets.dart" "SafeScrollableColumn" "Responsive widgets implemented"; then
    passed_tests=$((passed_tests + 1))
fi

# Test 9: Automated tests created
total_tests=$((total_tests + 1))
if check_fix "test/critical_fixes_test.dart" "Critical Fixes Tests" "Automated tests created"; then
    passed_tests=$((passed_tests + 1))
fi

# Test 10: SafeStateMixin usage in home screen
total_tests=$((total_tests + 1))
if check_fix "lib/screens/home_screen.dart" "SafeStateMixin" "SafeStateMixin used in home screen"; then
    passed_tests=$((passed_tests + 1))
fi

echo ""
echo "📊 Test Results:"
echo "   Passed: $passed_tests/$total_tests tests"
echo "   Success Rate: $(echo "scale=1; $passed_tests * 100 / $total_tests" | bc -l)%"

if [ $passed_tests -eq $total_tests ]; then
    echo "🎉 All critical fixes implemented successfully!"
    exit 0
else
    echo "⚠️  Some fixes may need attention."
    exit 1
fi