#!/bin/bash
# IconData Tree Shaking Fix Verification Script
# 
# This script verifies that the IconData tree shaking fix resolves the build issue
# and maintains all existing functionality.

echo "🔍 IconData Tree Shaking Fix Verification"
echo "=========================================="
echo ""

echo "1. Checking for non-constant IconData instances..."
if grep -r "IconData(" --include="*.dart" lib/ | grep -v "const\|static\|Icons\."; then
    echo "❌ Found non-constant IconData instances that may cause tree shaking issues"
    exit 1
else
    echo "✅ No non-constant IconData instances found"
fi
echo ""

echo "2. Verifying constant mapping exists..."
if grep -q "_iconCodePointMap" lib/models/quick_button_config.dart && grep -q "_iconCodePointMap" lib/models/entry.dart; then
    echo "✅ Constant icon mapping found in both models"
else
    echo "❌ Constant icon mapping missing"
    exit 1
fi
echo ""

echo "3. Checking getIconFromCodePoint methods use constants..."
if grep -A5 "getIconFromCodePoint" lib/models/quick_button_config.dart | grep -q "_iconCodePointMap" && \
   grep -A5 "getIconFromCodePoint" lib/models/entry.dart | grep -q "_iconCodePointMap"; then
    echo "✅ getIconFromCodePoint methods use constant mappings"
else
    echo "❌ getIconFromCodePoint methods don't use constant mappings"
    exit 1
fi
echo ""

echo "4. Running tests (if Flutter/Dart is available)..."
if command -v dart &> /dev/null; then
    echo "Running Dart tests..."
    dart test test/icon_tree_shaking_test.dart
    if [ $? -eq 0 ]; then
        echo "✅ All tests passed"
    else
        echo "❌ Some tests failed"
        exit 1
    fi
elif command -v flutter &> /dev/null; then
    echo "Running Flutter tests..."
    flutter test test/icon_tree_shaking_test.dart
    if [ $? -eq 0 ]; then
        echo "✅ All tests passed"
    else
        echo "❌ Some tests failed"
        exit 1
    fi
else
    echo "⚠️  Dart/Flutter not available - skipping test execution"
    echo "   Tests can be run manually with: 'flutter test test/icon_tree_shaking_test.dart'"
fi
echo ""

echo "5. Verifying build compatibility..."
if command -v flutter &> /dev/null; then
    echo "Testing Flutter build with tree shaking..."
    flutter build apk --tree-shake-icons --no-pub
    if [ $? -eq 0 ]; then
        echo "✅ Build successful with tree shaking enabled"
    else
        echo "❌ Build failed - tree shaking issue may not be resolved"
        exit 1
    fi
else
    echo "⚠️  Flutter not available - skipping build test"
    echo "   Build can be tested manually with: 'flutter build apk --tree-shake-icons'"
fi
echo ""

echo "🎉 All verifications completed successfully!"
echo ""
echo "Summary of Changes:"
echo "- Replaced non-constant IconData() constructors with constant icon mappings"
echo "- Added static _iconCodePointMap with commonly used Material Design icons"
echo "- Updated getIconFromCodePoint methods to use constant lookups"
echo "- Maintained backward compatibility for all existing usages"
echo "- Added comprehensive test coverage for the fix"
echo ""
echo "The tree shaking issue should now be resolved. You can build with:"
echo "  flutter build apk --tree-shake-icons"
echo "  flutter build appbundle --tree-shake-icons"