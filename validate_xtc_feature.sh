#!/bin/bash

# XTC Feature Validation Script
echo "🧪 Validating XTC Feature Implementation..."
echo "=========================================="

cd /home/runner/work/deinmudda/deinmudda

echo "📁 Checking required files exist..."
files=(
    "lib/models/xtc_substance.dart"
    "lib/widgets/xtc_color_picker.dart"
    "lib/widgets/xtc_quick_button.dart"
    "lib/screens/quick_entry/xtc_entry_dialog.dart"
    "test/xtc_functionality_test.dart"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file - MISSING"
    fi
done

echo ""
echo "🔍 Checking imports and references..."

echo "Checking XTC model usage:"
grep -r "XTCSubstance\|XTCForm\|XTCContent" lib/ --include="*.dart" | wc -l | xargs echo "  Found references:"

echo "Checking color picker usage:"
grep -r "XTCColorPicker" lib/ --include="*.dart" | wc -l | xargs echo "  Found references:"

echo "Checking quick button integration:"
grep -r "CompactXTCQuickButton" lib/ --include="*.dart" | wc -l | xargs echo "  Found references:"

echo ""
echo "📝 Code quality checks..."

echo "Checking for common issues:"
issues=0

# Check for missing imports
if grep -r "XTCSubstance" lib/ --include="*.dart" | grep -v "import.*xtc_substance"; then
    echo "⚠️  Potential missing XTCSubstance imports"
    ((issues++))
fi

# Check for proper error handling
if ! grep -r "try.*catch" lib/screens/quick_entry/xtc_entry_dialog.dart > /dev/null; then
    echo "⚠️  XTC dialog might be missing error handling"
    ((issues++))
fi

# Check for proper validation
if ! grep -r "validator.*value" lib/screens/quick_entry/xtc_entry_dialog.dart > /dev/null; then
    echo "⚠️  XTC dialog might be missing form validation"
    ((issues++))
fi

if [ $issues -eq 0 ]; then
    echo "✅ No obvious issues found"
else
    echo "⚠️  Found $issues potential issues"
fi

echo ""
echo "📊 Implementation Statistics:"
echo "XTC Model lines: $(wc -l < lib/models/xtc_substance.dart)"
echo "Color Picker lines: $(wc -l < lib/widgets/xtc_color_picker.dart)"
echo "Quick Button lines: $(wc -l < lib/widgets/xtc_quick_button.dart)"
echo "Entry Dialog lines: $(wc -l < lib/screens/quick_entry/xtc_entry_dialog.dart)"
echo "Tests lines: $(wc -l < test/xtc_functionality_test.dart)"

total_lines=$(($(wc -l < lib/models/xtc_substance.dart) + $(wc -l < lib/widgets/xtc_color_picker.dart) + $(wc -l < lib/widgets/xtc_quick_button.dart) + $(wc -l < lib/screens/quick_entry/xtc_entry_dialog.dart)))
echo "Total new code lines: $total_lines"

echo ""
echo "🎯 Feature Completeness Check:"

# Check all required features
features=(
    "XTCForm.rechteck.*XTCForm.stern.*XTCForm.kreis"
    "XTCContent.mdma.*XTCContent.mda.*XTCContent.amphetamin"
    "bruchrillen.*bool"
    "farbe.*Color"
    "gewicht.*double"
    "formattedMenge.*mg"
)

echo "Checking XTC forms (Rechteck, Stern, Kreis, etc.):"
if grep -q "rechteck.*stern.*kreis.*dreieck.*blume.*oval.*viereck.*pillenSpezifisch" lib/models/xtc_substance.dart; then
    echo "✅ All 8 forms implemented"
else
    echo "❌ Missing forms"
fi

echo "Checking XTC content types (MDMA, MDA, Amph., Unbekannt):"
if grep -q "mdma.*mda.*amphetamin.*unbekannt" lib/models/xtc_substance.dart; then
    echo "✅ All 4 content types implemented"
else
    echo "❌ Missing content types"
fi

echo "Checking color picker implementation:"
if grep -q "XTCColorPicker.*selectedColor.*onColorChanged" lib/widgets/xtc_color_picker.dart; then
    echo "✅ Color picker implemented"
else
    echo "❌ Color picker issues"
fi

echo "Checking quick button integration:"
if grep -q "CompactXTCQuickButton" lib/widgets/quick_entry/quick_entry_bar.dart; then
    echo "✅ Quick button integrated"
else
    echo "❌ Quick button not integrated"
fi

echo ""
echo "🏁 Validation Complete!"
echo "=========================================="