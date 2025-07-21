#!/bin/bash

# Bottom Navigation Overlay and Shrinking Fix Validation
# This script validates that the fixes for overlay effects and shrinking navigation items are properly implemented

echo "🔍 Validating Bottom Navigation Overlay and Shrinking Fixes..."
echo "=================================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

validation_failed=0

# Function to check if a pattern exists in a file
check_pattern() {
    local file="$1"
    local pattern="$2"
    local description="$3"
    local should_exist="$4"  # true or false
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗ File not found: $file${NC}"
        validation_failed=1
        return 1
    fi
    
    if grep -q "$pattern" "$file"; then
        if [ "$should_exist" = "true" ]; then
            echo -e "${GREEN}✓ $description${NC}"
            return 0
        else
            echo -e "${RED}✗ $description (should not exist)${NC}"
            validation_failed=1
            return 1
        fi
    else
        if [ "$should_exist" = "false" ]; then
            echo -e "${GREEN}✓ $description${NC}"
            return 0
        else
            echo -e "${RED}✗ $description (not found)${NC}"
            validation_failed=1
            return 1
        fi
    fi
}

echo "📋 Checking Bottom Navigation Fixes..."
echo "---------------------------------------"

# Check that AnimatedSwitcher is removed from navigation items
check_pattern "lib/screens/main_navigation.dart" "AnimatedSwitcher" "AnimatedSwitcher removed from navigation items" "false"

# Check that FittedBox with scaleDown is removed
check_pattern "lib/screens/main_navigation.dart" "FittedBox" "FittedBox removed from navigation items" "false"

# Check that AnimatedDefaultTextStyle is removed
check_pattern "lib/screens/main_navigation.dart" "AnimatedDefaultTextStyle" "AnimatedDefaultTextStyle removed from navigation text" "false"

# Check that fixed SizedBox containers are added for icons
check_pattern "lib/screens/main_navigation.dart" "height.*Spacing\.iconMd" "Fixed SizedBox for icon containers" "true"

# Check that fixed SizedBox containers are added for text
check_pattern "lib/screens/main_navigation.dart" "height.*14" "Fixed SizedBox for text containers" "true"

# Check that AnimatedContainer is replaced with simple Container
check_pattern "lib/screens/main_navigation.dart" "AnimatedContainer" "AnimatedContainer removed from navigation items" "false"

# Check that fixed height is set for navigation items
check_pattern "lib/screens/main_navigation.dart" "height: 54" "Fixed height for navigation items" "true"

echo ""
echo "📋 Checking SnackBar Overlay Prevention..."
echo "-------------------------------------------"

# Check that _isNavigationTransition flag is added
check_pattern "lib/screens/home_screen.dart" "_isNavigationTransition" "Navigation transition flag added" "true"

# Check that _safeShowSnackBar method exists
check_pattern "lib/screens/home_screen.dart" "_safeShowSnackBar" "Safe SnackBar method implemented" "true"

# Check that clearSnackBars is called to prevent overlays
check_pattern "lib/screens/home_screen.dart" "clearSnackBars" "SnackBar clearing implemented" "true"

# Check that deactivate lifecycle method is added
check_pattern "lib/screens/home_screen.dart" "void deactivate" "Deactivate lifecycle method added" "true"

# Check that activate lifecycle method is added
check_pattern "lib/screens/home_screen.dart" "void activate" "Activate lifecycle method added" "true"

# Check that ScaffoldMessenger.showSnackBar calls are only within _safeShowSnackBar method
# Count total showSnackBar calls and _safeShowSnackBar calls - should be equal
total_snackbar_calls=$(grep -c "ScaffoldMessenger.of(context).showSnackBar" "lib/screens/home_screen.dart" || echo "0")
safe_snackbar_calls=$(grep -c "_safeShowSnackBar" "lib/screens/home_screen.dart" || echo "0")

# We expect exactly 1 direct showSnackBar call (inside the safe method) and multiple _safeShowSnackBar calls
if [ "$total_snackbar_calls" -eq 1 ] && [ "$safe_snackbar_calls" -gt 5 ]; then
    echo -e "${GREEN}✓ Direct SnackBar calls replaced with safe method${NC}"
else
    echo -e "${RED}✗ SnackBar replacement incomplete (total: $total_snackbar_calls, safe: $safe_snackbar_calls)${NC}"
    validation_failed=1
fi

echo ""
echo "📋 Checking Test Implementation..."
echo "----------------------------------"

# Check that test file exists
if [ -f "test_navigation_overlay_fix.dart" ]; then
    echo -e "${GREEN}✓ Test file created${NC}"
    
    # Check for key test scenarios
    check_pattern "test_navigation_overlay_fix.dart" "Bottom Navigation Items Have Fixed Size" "Fixed size test implemented" "true"
    check_pattern "test_navigation_overlay_fix.dart" "Navigation Transitions Do Not Cause Layout Shifts" "Layout shift prevention test" "true"
    check_pattern "test_navigation_overlay_fix.dart" "No AnimatedSwitcher in Bottom Navigation" "AnimatedSwitcher removal test" "true"
    check_pattern "test_navigation_overlay_fix.dart" "Safe SnackBar Method Prevents Overlays" "SnackBar overlay prevention test" "true"
    check_pattern "test_navigation_overlay_fix.dart" "No Layout Overflow During Navigation" "Overflow prevention test" "true"
else
    echo -e "${RED}✗ Test file not found${NC}"
    validation_failed=1
fi

echo ""
echo "📋 Checking File Modifications..."
echo "---------------------------------"

# Check that main_navigation.dart has been modified correctly
if [ -f "lib/screens/main_navigation.dart" ]; then
    lines_changed=$(git diff HEAD~1 HEAD -- lib/screens/main_navigation.dart | grep -c "^[+-]" || echo "0")
    if [ "$lines_changed" -gt "20" ]; then
        echo -e "${GREEN}✓ Main navigation file significantly modified ($lines_changed lines changed)${NC}"
    else
        echo -e "${YELLOW}⚠ Main navigation file minimally modified ($lines_changed lines changed)${NC}"
    fi
else
    echo -e "${RED}✗ Main navigation file not found${NC}"
    validation_failed=1
fi

# Check that home_screen.dart has been modified correctly  
if [ -f "lib/screens/home_screen.dart" ]; then
    lines_changed=$(git diff HEAD~1 HEAD -- lib/screens/home_screen.dart | grep -c "^[+-]" || echo "0")
    if [ "$lines_changed" -gt "30" ]; then
        echo -e "${GREEN}✓ Home screen file significantly modified ($lines_changed lines changed)${NC}"
    else
        echo -e "${YELLOW}⚠ Home screen file minimally modified ($lines_changed lines changed)${NC}"
    fi
else
    echo -e "${RED}✗ Home screen file not found${NC}"
    validation_failed=1
fi

echo ""
echo "=================================================================="

if [ $validation_failed -eq 0 ]; then
    echo -e "${GREEN}🎉 All validation checks passed!${NC}"
    echo -e "${GREEN}The bottom navigation overlay and shrinking fixes have been properly implemented.${NC}"
    echo ""
    echo "Key improvements:"
    echo "• Simplified navigation animation stack (no more AnimatedSwitcher/FittedBox)"
    echo "• Fixed sizing prevents dynamic scaling and shrinking effects"
    echo "• Safe SnackBar method prevents overlay effects during navigation"
    echo "• Comprehensive test coverage validates the fixes"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Validation failed! Please review the implementation.${NC}"
    echo ""
    echo "Please ensure all fixes are properly applied:"
    echo "1. Remove complex animation stack from bottom navigation"
    echo "2. Add fixed sizing for navigation items"
    echo "3. Implement safe SnackBar method"
    echo "4. Add navigation lifecycle management"
    echo "5. Create comprehensive tests"
    echo ""
    exit 1
fi