#!/bin/bash

# ActiveTimerBar Overflow Fix Validation Script

echo "🔍 ActiveTimerBar Overflow Fix Validation"
echo "=========================================="

# Check if dart is available
if ! command -v dart &> /dev/null; then
    echo "❌ Dart not found. Please install Flutter/Dart to run validation."
    exit 1
fi

echo "✅ Dart found"

# Navigate to project directory
cd "$(dirname "$0")"

echo ""
echo "📝 Running focused overflow tests..."

# Run the specific overflow tests
echo "🧪 Testing ActiveTimerBar overflow fixes..."
if dart test test/active_timer_bar_overflow_test.dart; then
    echo "✅ ActiveTimerBar overflow tests passed"
else
    echo "❌ ActiveTimerBar overflow tests failed"
    FAILED_TESTS=1
fi

echo ""
echo "🧪 Testing QuickButton timer display..."
if dart test test/quick_button_timer_display_test.dart; then
    echo "✅ QuickButton timer display tests passed"
else
    echo "❌ QuickButton timer display tests failed"
    FAILED_TESTS=1
fi

echo ""
echo "🧪 Testing existing overflow-related tests..."
if dart test test/quick_entry_bar_overflow_test.dart; then
    echo "✅ QuickEntryBar overflow tests passed"
else
    echo "❌ QuickEntryBar overflow tests failed"
    FAILED_TESTS=1
fi

if dart test test/animated_switcher_overflow_test.dart; then
    echo "✅ AnimatedSwitcher overflow tests passed"
else
    echo "❌ AnimatedSwitcher overflow tests failed"
    FAILED_TESTS=1
fi

echo ""
echo "📊 Validation Summary:"
echo "====================="

if [ "$FAILED_TESTS" = "1" ]; then
    echo "❌ Some tests failed. Please review the test output above."
    echo ""
    echo "🔧 Common fixes for test failures:"
    echo "   • Ensure all required dependencies are in pubspec.yaml"
    echo "   • Check that mock services are properly configured"
    echo "   • Verify Widget structure matches test expectations"
    exit 1
else
    echo "✅ All overflow fix tests passed!"
    echo ""
    echo "📱 Manual Testing Checklist:"
    echo "   □ Test ActiveTimerBar with height constraint of 33px"
    echo "   □ Verify QuickButton timer display shows active timers"
    echo "   □ Check responsive layout on different screen sizes"
    echo "   □ Validate text truncation works correctly"
    echo "   □ Ensure no visual overflow in HomeScreen"
    echo ""
    echo "🎉 ActiveTimerBar overflow fixes are ready for testing!"
fi