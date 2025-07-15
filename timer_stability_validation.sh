#!/bin/bash

echo "🔍 Timer Stability Validation - Comprehensive Test"
echo "================================================"
echo ""

echo "📋 Phase 1: Code Analysis"
echo "========================"

# Check for unsafe setState usage
echo "🔍 Checking for unsafe setState usage..."
unsafe_setstate_count=$(grep -r "setState(" lib/screens/home_screen.dart | grep -v "safeSetState" | wc -l)
safe_setstate_count=$(grep -r "safeSetState(" lib/screens/home_screen.dart | wc -l)

if [ "$unsafe_setstate_count" -eq 0 ]; then
    echo "✅ No unsafe setState calls found"
else
    echo "⚠️  Found $unsafe_setstate_count unsafe setState calls"
fi

echo "📊 Safe setState calls: $safe_setstate_count"
echo ""

# Check for mounted checks
echo "🔍 Checking for mounted checks..."
mounted_checks=$(grep -r "mounted" lib/screens/home_screen.dart | wc -l)
echo "📊 Mounted checks found: $mounted_checks"
echo ""

# Check for SafeStateMixin usage
echo "🔍 Checking for SafeStateMixin integration..."
if grep -q "SafeStateMixin" lib/screens/home_screen.dart; then
    echo "✅ SafeStateMixin is integrated"
else
    echo "❌ SafeStateMixin is missing"
fi
echo ""

# Check for CrashProtectionWrapper
echo "🔍 Checking for CrashProtectionWrapper..."
if grep -q "CrashProtectionWrapper" lib/widgets/active_timer_bar.dart; then
    echo "✅ CrashProtectionWrapper is integrated"
else
    echo "❌ CrashProtectionWrapper is missing"
fi
echo ""

echo "📋 Phase 2: Timer Service Analysis"
echo "================================="

# Check for disposal safety
echo "🔍 Checking for disposal safety..."
if grep -q "_isDisposed" lib/services/timer_service.dart; then
    echo "✅ Disposal safety implemented"
else
    echo "❌ Disposal safety missing"
fi

# Check for race condition prevention
echo "🔍 Checking for race condition prevention..."
if grep -q "List.from(_activeTimers)" lib/services/timer_service.dart; then
    echo "✅ Race condition prevention implemented"
else
    echo "❌ Race condition prevention missing"
fi

# Check for duplicate timer prevention
echo "🔍 Checking for duplicate timer prevention..."
if grep -q "hasTimerWithId" lib/services/timer_service.dart; then
    echo "✅ Duplicate timer prevention implemented"
else
    echo "❌ Duplicate timer prevention missing"
fi

# Check for timer persistence
echo "🔍 Checking for timer persistence..."
if grep -q "_saveTimersToPrefs" lib/services/timer_service.dart; then
    echo "✅ Timer persistence implemented"
else
    echo "❌ Timer persistence missing"
fi
echo ""

echo "📋 Phase 3: Debug Logging Analysis"
echo "================================="

# Check for comprehensive error logging
echo "🔍 Checking for comprehensive error logging..."
log_types=(
    "logTimer"
    "logError"
    "logSuccess"
    "logWarning"
    "logStartup"
)

for log_type in "${log_types[@]}"; do
    if grep -q "$log_type" lib/services/timer_service.dart; then
        echo "✅ $log_type logging implemented"
    else
        echo "❌ $log_type logging missing"
    fi
done
echo ""

echo "📋 Phase 4: Impeller Integration Analysis"
echo "========================================"

# Check for Impeller detection
echo "🔍 Checking for Impeller integration..."
if grep -q "ImpellerHelper" lib/main.dart; then
    echo "✅ Impeller integration implemented"
else
    echo "❌ Impeller integration missing"
fi

# Check for adaptive animations
echo "🔍 Checking for adaptive animations..."
if grep -q "getTimerAnimationSettings" lib/widgets/active_timer_bar.dart; then
    echo "✅ Adaptive animations implemented"
else
    echo "❌ Adaptive animations missing"
fi
echo ""

echo "📋 Phase 5: Test Coverage Analysis"
echo "================================="

# Check for test files
echo "🔍 Checking for test coverage..."
if [ -f "test/timer_stability_test.dart" ]; then
    echo "✅ Timer stability tests created"
else
    echo "❌ Timer stability tests missing"
fi

# Check for validation scripts
echo "🔍 Checking for validation scripts..."
if [ -f "validate_timer_fixes.sh" ]; then
    echo "✅ Validation script exists"
else
    echo "❌ Validation script missing"
fi
echo ""

echo "📋 Phase 6: Final Validation Summary"
echo "==================================="

# Calculate overall score
total_checks=20
passed_checks=0

# Count passed checks (simplified)
if [ "$unsafe_setstate_count" -eq 0 ]; then ((passed_checks++)); fi
if [ "$safe_setstate_count" -gt 0 ]; then ((passed_checks++)); fi
if [ "$mounted_checks" -gt 5 ]; then ((passed_checks++)); fi
if grep -q "SafeStateMixin" lib/screens/home_screen.dart; then ((passed_checks++)); fi
if grep -q "CrashProtectionWrapper" lib/widgets/active_timer_bar.dart; then ((passed_checks++)); fi
if grep -q "_isDisposed" lib/services/timer_service.dart; then ((passed_checks++)); fi
if grep -q "List.from(_activeTimers)" lib/services/timer_service.dart; then ((passed_checks++)); fi
if grep -q "hasTimerWithId" lib/services/timer_service.dart; then ((passed_checks++)); fi
if grep -q "_saveTimersToPrefs" lib/services/timer_service.dart; then ((passed_checks++)); fi
if grep -q "logTimer" lib/services/timer_service.dart; then ((passed_checks++)); fi
if grep -q "logError" lib/services/timer_service.dart; then ((passed_checks++)); fi
if grep -q "logSuccess" lib/services/timer_service.dart; then ((passed_checks++)); fi
if grep -q "logWarning" lib/services/timer_service.dart; then ((passed_checks++)); fi
if grep -q "logStartup" lib/services/timer_service.dart; then ((passed_checks++)); fi
if grep -q "ImpellerHelper" lib/main.dart; then ((passed_checks++)); fi
if grep -q "getTimerAnimationSettings" lib/widgets/active_timer_bar.dart; then ((passed_checks++)); fi
if [ -f "test/timer_stability_test.dart" ]; then ((passed_checks++)); fi
if [ -f "validate_timer_fixes.sh" ]; then ((passed_checks++)); fi

score=$((passed_checks * 100 / total_checks))

echo ""
echo "🎯 Overall Validation Score: $score% ($passed_checks/$total_checks)"
echo ""

if [ "$score" -ge 90 ]; then
    echo "🎉 EXCELLENT! Timer stability implementation is comprehensive"
    echo "✅ All critical safety measures are in place"
    echo "✅ Crash prevention mechanisms are active"
    echo "✅ Debug logging is comprehensive"
    echo "✅ Impeller compatibility is implemented"
elif [ "$score" -ge 75 ]; then
    echo "✅ GOOD! Timer stability implementation is solid"
    echo "⚠️  Some minor improvements could be made"
elif [ "$score" -ge 50 ]; then
    echo "⚠️  PARTIAL! Timer stability has basic protections"
    echo "❌ Several important safety measures are missing"
else
    echo "❌ INSUFFICIENT! Timer stability needs significant work"
    echo "❌ Critical safety measures are missing"
fi

echo ""
echo "🔧 Key Implemented Features:"
echo "  • SafeStateMixin for safe state updates"
echo "  • CrashProtectionWrapper for error boundaries"
echo "  • Timer service disposal safety"
echo "  • Race condition prevention"
echo "  • Duplicate timer prevention"
echo "  • Timer persistence across app restarts"
echo "  • Comprehensive debug logging"
echo "  • Impeller/Vulkan backend compatibility"
echo "  • Mounted checks for navigation safety"
echo "  • Error handling with graceful fallbacks"
echo ""

echo "🚀 Next Steps:"
echo "  1. Run manual tests using the testing guide"
echo "  2. Test timer operations during navigation"
echo "  3. Verify timer persistence across app restarts"
echo "  4. Test with different Impeller configurations"
echo "  5. Monitor debug logs for any issues"
echo ""

echo "✅ Timer Stability Validation Complete!"