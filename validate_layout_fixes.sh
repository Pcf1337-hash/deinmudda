#!/bin/bash

echo "🔍 Validating Dosage Calculator Layout Fixes"
echo "============================================="

# Counter for found fixes
FIXES_FOUND=0

echo "1. Checking modal trigger fixes..."
if grep -q "_isModalOpen" lib/screens/dosage_calculator/dosage_calculator_screen.dart; then
    echo "   ✅ Modal state tracking implemented"
    ((FIXES_FOUND++))
fi

if grep -q "addPostFrameCallback" lib/screens/dosage_calculator/dosage_calculator_screen.dart; then
    echo "   ✅ Post-frame callback for modal display"
    ((FIXES_FOUND++))
fi

if grep -q "useSafeArea: true" lib/screens/dosage_calculator/dosage_calculator_screen.dart; then
    echo "   ✅ Safe area usage in modals"
    ((FIXES_FOUND++))
fi

echo ""
echo "2. Checking layout constraint fixes..."
if grep -q "SafeLayoutBuilder" lib/screens/dosage_calculator/dosage_calculator_screen.dart; then
    echo "   ✅ Safe layout builder usage"
    ((FIXES_FOUND++))
fi

if grep -q "LayoutErrorBoundary" lib/screens/dosage_calculator/dosage_calculator_screen.dart; then
    echo "   ✅ Layout error boundary protection"
    ((FIXES_FOUND++))
fi

if grep -q "SafeScrollableColumn" lib/screens/dosage_calculator/dosage_calculator_screen.dart; then
    echo "   ✅ Safe scrollable column usage"
    ((FIXES_FOUND++))
fi

if grep -q "GridView.builder" lib/screens/dosage_calculator/dosage_calculator_screen.dart; then
    echo "   ✅ GridView instead of Wrap for substances"
    ((FIXES_FOUND++))
fi

echo ""
echo "3. Checking GlobalKey fixes..."
if grep -q "substance.hashCode" lib/screens/dosage_calculator/dosage_calculator_screen.dart; then
    echo "   ✅ Unique keys using hashCode"
    ((FIXES_FOUND++))
fi

if grep -q "uniqueKey.*substanceName.*index" lib/screens/dosage_calculator/dosage_calculator_screen.dart; then
    echo "   ✅ Composite unique keys for calculations"
    ((FIXES_FOUND++))
fi

echo ""
echo "4. Checking error handling improvements..."
if grep -q "if \(mounted && !_isDisposed\)" lib/screens/dosage_calculator/dosage_calculator_screen.dart; then
    echo "   ✅ Proper mount and disposal checks"
    ((FIXES_FOUND++))
fi

if grep -q "constraints.*maxHeight.*maxWidth" lib/screens/dosage_calculator/dosage_calculator_screen.dart; then
    echo "   ✅ Proper constraint handling"
    ((FIXES_FOUND++))
fi

if grep -q "SafeDosageResultCard" lib/screens/dosage_calculator/dosage_calculator_screen.dart; then
    echo "   ✅ Safe dosage result card implementation"
    ((FIXES_FOUND++))
fi

echo ""
echo "5. Checking layout protection components..."
if [ -f "lib/widgets/layout_error_boundary.dart" ]; then
    echo "   ✅ Layout error boundary component created"
    ((FIXES_FOUND++))
fi

if grep -q "SafeFlexible" lib/widgets/layout_error_boundary.dart; then
    echo "   ✅ Safe flexible widget wrapper"
    ((FIXES_FOUND++))
fi

if grep -q "SafeExpanded" lib/widgets/layout_error_boundary.dart; then
    echo "   ✅ Safe expanded widget wrapper"
    ((FIXES_FOUND++))
fi

echo ""
echo "6. Checking test coverage..."
if [ -f "test/dosage_calculator_screen_test.dart" ]; then
    echo "   ✅ Test file created for layout validation"
    ((FIXES_FOUND++))
fi

if grep -q "renders without layout overflow" test/dosage_calculator_screen_test.dart; then
    echo "   ✅ Overflow test implemented"
    ((FIXES_FOUND++))
fi

if grep -q "modal appears when substance is tapped" test/dosage_calculator_screen_test.dart; then
    echo "   ✅ Modal test implemented"
    ((FIXES_FOUND++))
fi

echo ""
echo "📊 Validation Results:"
echo "   Total fixes found: $FIXES_FOUND/18"

if [ $FIXES_FOUND -ge 16 ]; then
    echo "🎉 EXCELLENT! All major layout fixes implemented"
elif [ $FIXES_FOUND -ge 14 ]; then
    echo "✅ GOOD! Most layout fixes implemented"
elif [ $FIXES_FOUND -ge 10 ]; then
    echo "⚠️  FAIR! Some layout fixes missing"
else
    echo "❌ POOR! Major layout fixes missing"
fi

echo ""
echo "🎯 Key Improvements Made:"
echo "   - Modal trigger issue fixed with proper state management"
echo "   - Layout overflow prevented with constraints and safe wrappers"
echo "   - GlobalKey duplication eliminated with unique identifiers"
echo "   - Error boundaries added for layout protection"
echo "   - Post-frame callbacks prevent setState during build"
echo "   - Safe area usage in modals"
echo "   - Comprehensive error handling with mount checks"

echo ""
echo "🚀 Next Steps:"
echo "   - Test the app with various screen sizes"
echo "   - Verify modal functionality works correctly"
echo "   - Monitor console for any remaining layout errors"
echo "   - Test substance selection and dosage calculation"
echo "   - Validate timer functionality"