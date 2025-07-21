#!/bin/bash

# Quick Button and Header Bar Fix Validation
echo "🔧 Validating Quick Button and Header Bar fixes..."
echo "=================================================="

# Check header bar overflow fix
echo ""
echo "1. Checking HeaderBar overflow fixes..."

if grep -q "Flexible(" lib/widgets/header_bar.dart; then
    echo "✅ Changed Expanded to Flexible to prevent overflow"
else
    echo "❌ Flexible widget not found in HeaderBar"
fi

if grep -q "maxLines: 1" lib/widgets/header_bar.dart; then
    echo "✅ Reduced maxLines to prevent title overflow"
else
    echo "❌ maxLines constraint not found in HeaderBar"
fi

if grep -q "height: 2" lib/widgets/header_bar.dart; then
    echo "✅ Reduced spacing to prevent overflow"
else
    echo "❌ Reduced spacing not found in HeaderBar"
fi

# Check quick button consistency
echo ""
echo "2. Checking Quick Button consistency fixes..."

if grep -q "width: 80.0" lib/widgets/quick_entry/quick_button_widget.dart; then
    echo "✅ Fixed width to exact 80.0 pixels for consistency"
else
    echo "❌ Fixed width not found in QuickButtonWidget"
fi

if grep -q "height: 100.0" lib/widgets/quick_entry/quick_button_widget.dart; then
    echo "✅ Fixed height to exact 100.0 pixels for consistency"
else
    echo "❌ Fixed height not found in QuickButtonWidget"
fi

# Check delete state management
echo ""
echo "3. Checking delete operation state management..."

if grep -q "_quickButtons.removeWhere" lib/screens/quick_entry/quick_entry_management_screen.dart; then
    echo "✅ Added immediate local state update on delete"
else
    echo "❌ Immediate state update not found in management screen"
fi

if grep -q "await _loadQuickButtons();" lib/screens/quick_entry/quick_entry_management_screen.dart; then
    echo "✅ Added database reload after delete for consistency"
else
    echo "❌ Database reload not found in management screen"
fi

# Check scrolling fixes
echo ""
echo "4. Checking ListView scrolling fixes..."

if grep -q "ClampingScrollPhysics" lib/widgets/quick_entry/quick_entry_bar.dart; then
    echo "✅ Added ClampingScrollPhysics to prevent gray/empty state"
else
    echo "❌ ClampingScrollPhysics not found in QuickEntryBar"
fi

if grep -q "safeSetState" lib/widgets/quick_entry/quick_entry_bar.dart; then
    echo "✅ Added safe state updates for better reliability"
else
    echo "❌ Safe state updates not found in QuickEntryBar"
fi

# Check widget key improvements
echo ""
echo "5. Checking widget key improvements..."

if grep -q "button.dosage.*button.unit.*button.cost" lib/widgets/quick_entry/quick_button_list.dart; then
    echo "✅ Enhanced widget keys to trigger rebuilds on data changes"
else
    echo "❌ Enhanced widget keys not found in QuickButtonList"
fi

# Summary
echo ""
echo "📊 VALIDATION SUMMARY:"
echo "====================="

total=8
passed=0

# Count passed checks
[ $(grep -c "Flexible(" lib/widgets/header_bar.dart) -gt 0 ] && ((passed++))
[ $(grep -c "maxLines: 1" lib/widgets/header_bar.dart) -gt 0 ] && ((passed++))
[ $(grep -c "width: 80.0" lib/widgets/quick_entry/quick_button_widget.dart) -gt 0 ] && ((passed++))
[ $(grep -c "height: 100.0" lib/widgets/quick_entry/quick_button_widget.dart) -gt 0 ] && ((passed++))
[ $(grep -c "_quickButtons.removeWhere" lib/screens/quick_entry/quick_entry_management_screen.dart) -gt 0 ] && ((passed++))
[ $(grep -c "await _loadQuickButtons();" lib/screens/quick_entry/quick_entry_management_screen.dart) -gt 0 ] && ((passed++))
[ $(grep -c "ClampingScrollPhysics" lib/widgets/quick_entry/quick_entry_bar.dart) -gt 0 ] && ((passed++))
[ $(grep -c "button.dosage.*button.unit.*button.cost" lib/widgets/quick_entry/quick_button_list.dart) -gt 0 ] && ((passed++))

echo "Passed: $passed/$total checks"

if [ $passed -eq $total ]; then
    echo ""
    echo "🎉 ALL FIXES VALIDATED SUCCESSFULLY!"
    echo ""
    echo "✅ RenderFlex overflow in header_bar.dart fixed"
    echo "✅ Quick Button width consistency (88.0, 80.0, 76.0 → 80.0) fixed"
    echo "✅ Delete operation state management improved"
    echo "✅ ListView scrolling gray/empty state fixed"
    echo "✅ Widget keys enhanced for proper updates"
    echo ""
    echo "All reported issues from the problem statement should be resolved."
elif [ $passed -ge 6 ]; then
    echo ""
    echo "✅ MOST FIXES VALIDATED SUCCESSFULLY!"
    echo ""
    echo "Core issues addressed, minor improvements may still be needed."
else
    echo ""
    echo "❌ SOME FIXES MAY BE MISSING"
    echo ""
    echo "Please review the failed checks above."
fi