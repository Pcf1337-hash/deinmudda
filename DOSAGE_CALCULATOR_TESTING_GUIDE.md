# Dosage Calculator Testing Guide

This guide helps verify that all the dosage calculation improvements are working correctly.

## Test Scenarios

### 1. Text Label Changes ✓
**Expected**: All dosage labels should show "Optimale Dosis" instead of "Empfohlene Dosis"

**Test Steps**:
1. Open main dosage calculator screen
2. Check substance cards show "Optimale Dosis (-20%)" 
3. Open substance search screen
4. Check substance cards show "Optimale Dosis"
5. Open any substance detail view
6. Check modal shows "Optimale Dosis"

### 2. Enhanced Dosage Logic in Substance Search ✓
**Expected**: Substance search cards should show calculated dosages when user profile exists

**Test Steps**:
1. Create a user profile with specific weight (e.g., 75kg)
2. Open substance search screen
3. Verify substance cards show:
   - "Optimale Dosis" section with calculated mg value
   - User weight displayed (e.g., "39.2 mg bei 75.0 kg")
   - Gradient background styling
   - Proper dosage reduction applied (-20% for optimal strategy)

### 3. Duration Display Improvements ✓ 
**Expected**: All duration displays should show proper styling and values

**Test Steps**:
1. Check main dosage calculator substance cards
2. Verify duration shows as "⏱ 4–6 Stunden" (not "– –")
3. Check font size is larger (13-14px)
4. Verify white text color with shadow
5. Check text doesn't overflow on small cards
6. Test in substance search cards and detail modals

### 4. User Experience Improvements ✓
**Expected**: Better flow and user guidance

**Test Steps**:
1. Open substance detail from search
2. Verify normal dose is pre-selected (not light dose)
3. Without user profile, click "Profil erstellen & berechnen"
4. Verify enhanced dialog shows benefits of creating profile
5. With user profile, verify dosage strategy is applied correctly

### 5. Complete Calculation Logic ✓
**Expected**: All calculations should apply user dosage strategies

**Test Steps**:
1. Create user profile with "Optimal" strategy (-20%)
2. Calculate dosage for any substance
3. Verify calculation: optimalDose = weight * dosePerKg * (1.0 - 0.2)
4. Test with different weights and substances
5. Verify consistency across main calculator and search screens

## Key Implementation Details

### Dosage Calculation Formula
```dart
final calculatedDose = substance.calculateDosage(userWeight, DosageIntensity.normal);
final optimalDose = user.getRecommendedDose(calculatedDose);
// For optimal strategy: optimalDose = calculatedDose * (1.0 - 0.2)
```

### Duration Display Enhancement
```dart
// Enhanced getter in DosageCalculatorSubstance
String get durationWithIcon => '⏱ ${durationDisplay}';
String get durationDisplay => duration.isEmpty ? 'Unbekannte Dauer' : duration;
```

### Styling Improvements
- Duration text: White color with black shadow for contrast
- Font size: 13-14px for better readability
- Overflow handling: `TextOverflow.ellipsis`, `maxLines: 1`, `softWrap: false`
- Enhanced gradients and visual hierarchy

## Expected Results

1. **No "Empfohlene Dosis" text** should appear anywhere
2. **Duration displays** should show actual values like "⏱ 4–6 Stunden" with proper styling
3. **Substance search cards** should show calculated dosages when user profile exists
4. **Detail modals** should pre-select normal dose and apply user strategies
5. **Create profile dialog** should show benefits and be visually enhanced
6. **All calculations** should be consistent between main calculator and search screens

## Common Issues to Check

1. **Missing duration values**: Should show "Unbekannte Dauer" as fallback
2. **Calculation inconsistencies**: Verify same substance shows same dosage in both screens
3. **Profile requirements**: Ensure proper handling when no profile exists
4. **Visual overflow**: Check text doesn't overflow on small screens
5. **Strategy application**: Verify -20% reduction is actually applied for optimal strategy