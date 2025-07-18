#!/bin/bash

# Navigation Overflow Fix Validation Script
echo "🔍 Validating Navigation Overflow Fixes..."

# Check if required files exist
MAIN_NAV_FILE="lib/screens/main_navigation.dart"
HOME_SCREEN_FILE="lib/screens/home_screen.dart"
LAYOUT_BOUNDARY_FILE="lib/widgets/layout_error_boundary.dart"

echo "📁 Checking required files..."

if [ ! -f "$MAIN_NAV_FILE" ]; then
    echo "❌ MainNavigation file not found: $MAIN_NAV_FILE"
    exit 1
fi

if [ ! -f "$HOME_SCREEN_FILE" ]; then
    echo "❌ HomeScreen file not found: $HOME_SCREEN_FILE"
    exit 1
fi

if [ ! -f "$LAYOUT_BOUNDARY_FILE" ]; then
    echo "❌ LayoutErrorBoundary file not found: $LAYOUT_BOUNDARY_FILE"
    exit 1
fi

echo "✅ All required files found"

# Check for unique keys in MainNavigation
echo "🔑 Checking for unique keys in MainNavigation..."
if grep -q "ValueKey('home_screen')" "$MAIN_NAV_FILE" && \
   grep -q "ValueKey('dosage_calculator_screen')" "$MAIN_NAV_FILE" && \
   grep -q "ValueKey('statistics_screen')" "$MAIN_NAV_FILE" && \
   grep -q "ValueKey('menu_screen')" "$MAIN_NAV_FILE"; then
    echo "✅ Unique keys added to screen widgets"
else
    echo "❌ Missing unique keys for screen widgets"
    exit 1
fi

# Check for clamped bottom padding to prevent extreme values
echo "🔒 Checking for clamped bottom padding..."
if grep -q "clamp(0.0, 50.0)" "$MAIN_NAV_FILE"; then
    echo "✅ Bottom padding clamped to prevent extreme values"
else
    echo "❌ Bottom padding not properly clamped"
    exit 1
fi

# Check for layout error boundaries in HomeScreen
echo "🛡️ Checking for LayoutErrorBoundary usage..."
if grep -q "LayoutErrorBoundary" "$HOME_SCREEN_FILE"; then
    echo "✅ LayoutErrorBoundary implemented in HomeScreen"
else
    echo "❌ LayoutErrorBoundary not found in HomeScreen"
    exit 1
fi

# Check for container constraints to prevent overflow
echo "📏 Checking for container constraints..."
if grep -q "BoxConstraints" "$HOME_SCREEN_FILE" && \
   grep -q "maxHeight:" "$HOME_SCREEN_FILE"; then
    echo "✅ Container constraints added to prevent overflow"
else
    echo "❌ Missing container constraints"
    exit 1
fi

# Check for ClampingScrollPhysics
echo "📱 Checking for ClampingScrollPhysics..."
if grep -q "ClampingScrollPhysics" "$HOME_SCREEN_FILE"; then
    echo "✅ ClampingScrollPhysics added for consistent scrolling"
else
    echo "❌ ClampingScrollPhysics not found"
    exit 1
fi

# Check for mounted checks in navigation
echo "🏠 Checking for mounted checks..."
if grep -q "if (!mounted) return;" "$MAIN_NAV_FILE"; then
    echo "✅ Mounted checks added to prevent disposed widget operations"
else
    echo "❌ Missing mounted checks"
    exit 1
fi

# Check for Flexible widgets in navigation items
echo "🤸 Checking for Flexible widgets..."
if grep -q "Flexible(" "$MAIN_NAV_FILE"; then
    echo "✅ Flexible widgets used for responsive layout"
else
    echo "❌ Missing Flexible widgets"
    exit 1
fi

# Check for maxLines and overflow handling
echo "📝 Checking for text overflow handling..."
if grep -q "maxLines:" "$MAIN_NAV_FILE" && \
   grep -q "TextOverflow.ellipsis" "$MAIN_NAV_FILE"; then
    echo "✅ Text overflow handling implemented"
else
    echo "❌ Missing text overflow handling"
    exit 1
fi

# Check for error boundary in PageView
echo "📖 Checking for PageView error boundary..."
if grep -q "LayoutErrorBoundary" "$MAIN_NAV_FILE" && \
   grep -q "Main Navigation PageView" "$MAIN_NAV_FILE"; then
    echo "✅ PageView wrapped with error boundary"
else
    echo "❌ PageView not properly protected with error boundary"
    exit 1
fi

# Check for imports of LayoutErrorBoundary
echo "📦 Checking for LayoutErrorBoundary imports..."
if grep -q "import.*layout_error_boundary" "$MAIN_NAV_FILE" && \
   grep -q "import.*layout_error_boundary" "$HOME_SCREEN_FILE"; then
    echo "✅ LayoutErrorBoundary properly imported"
else
    echo "❌ LayoutErrorBoundary not properly imported"
    exit 1
fi

echo ""
echo "🎉 All navigation overflow fixes validated successfully!"
echo ""
echo "📋 Summary of fixes applied:"
echo "   ✅ Added unique ValueKey to each screen widget"
echo "   ✅ Clamped bottom padding to prevent extreme values"
echo "   ✅ Wrapped critical sections with LayoutErrorBoundary"
echo "   ✅ Added container constraints to prevent overflow"
echo "   ✅ Implemented ClampingScrollPhysics for consistent scrolling"
echo "   ✅ Added mounted checks to prevent disposed widget operations"
echo "   ✅ Used Flexible widgets for responsive navigation layout"
echo "   ✅ Implemented text overflow handling with maxLines and ellipsis"
echo "   ✅ Protected PageView with error boundary"
echo "   ✅ Proper import statements for error boundaries"
echo ""
echo "🚀 These fixes should resolve:"
echo "   • Extreme pixel overflow (99991 pixels) errors"
echo "   • Duplicate key conflicts during navigation"
echo "   • Layout calculation errors in bottom navigation"
echo "   • Unnecessary screen recreation during navigation transitions"
echo ""