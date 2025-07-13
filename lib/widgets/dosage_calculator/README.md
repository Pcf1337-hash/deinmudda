# Improved Substance Cards - Glassmorphism Design

This implementation provides a modern, glassmorphism-styled substance card system for the dosage calculator with neon effects and responsive design.

## 🎨 Design Features

### Glassmorphism Effects
- **Backdrop blur**: Uses `BackdropFilter` with `ImageFilter.blur(sigmaX: 10, sigmaY: 10)`
- **Translucent backgrounds**: Gradient with `Colors.white.withOpacity(0.15)` to `Colors.white.withOpacity(0.05)`
- **Rounded corners**: `BorderRadius.circular(16)` for modern appearance
- **Smooth shadows**: Multiple `BoxShadow` layers for depth

### Neon Effects
- **Substance-specific colors**: Each substance has its unique color scheme
  - MDMA: Pink/Magenta (`#FF10F0`)
  - LSD: Purple (`#9D4EDD`)
  - Ketamin: Blue (`#0080FF`)
  - Kokain: Orange (`#FFA500`)
  - Cannabis: Green (`#22C55E`)
  - Psilocybin: Violet (`#8B5CF6`)
  - Amphetamine: Red (`#EF4444`)
- **Animated glow**: Hover effects with increased shadow intensity
- **Colored borders**: `Border.all(color: substanceColor.withOpacity(0.3), width: 1.2)`

## 📱 Responsive Design

### Layout Behavior
- **Wide screens (≥600px)**: Two cards side by side
- **Narrow screens (<600px)**: One card per row
- **Implementation**: Uses `LayoutBuilder` with `Wrap` for automatic wrapping

### Text Handling
- **Overflow protection**: All text uses `maxLines: 2` and `overflow: TextOverflow.ellipsis`
- **Responsive scaling**: Uses `FittedBox` for proper text scaling
- **Flexible layout**: Uses `Flexible` widgets for dynamic sizing

## 💊 Card Content

### Required Information
1. **Substance name**: Prominently displayed with substance-specific color
2. **Icon**: Contextual icon based on substance type
3. **Administration route**: E.g., "Oral (Mund)", "Nasal (Nase)"
4. **Duration**: E.g., "4–6 Stunden", "8–12 Stunden"
5. **Danger level**: Color-coded badge (High/Medium/Low)

### Dosage Information
- **Recommended dose**: Normal dose based on user weight
- **Optional dose**: 80% of normal dose (automatically calculated)
- **Dosage range**: Light, Normal, Strong doses per kg
- **Calculate button**: Triggers dosage calculation

## 🔧 Implementation Details

### Core Components

#### `ImprovedSubstanceCard`
```dart
ImprovedSubstanceCard(
  substance: DosageCalculatorSubstance,
  user: DosageCalculatorUser?, // Optional for dose calculations
  onTap: VoidCallback?,
  isCompact: bool = false,
)
```

#### `ResponsiveSubstanceCardGrid`
```dart
ResponsiveSubstanceCardGrid(
  substances: List<DosageCalculatorSubstance>,
  user: DosageCalculatorUser?,
  onCardTap: Function(DosageCalculatorSubstance)?,
)
```

### Flutter Widgets Used
- ✅ `LayoutBuilder` - For responsive layout detection
- ✅ `Wrap` - For card wrapping behavior
- ✅ `Flexible` - For flexible text content
- ✅ `FittedBox` - For proper text scaling
- ✅ `AnimatedBuilder` - For smooth hover animations
- ✅ `MouseRegion` - For hover detection
- ✅ `BackdropFilter` - For glassmorphism blur effects

### Animation System
- **Hover controller**: `AnimationController` with 300ms duration
- **Scale animation**: Cards scale down slightly on hover (0.98x)
- **Glow animation**: Shadow intensity increases on hover
- **Smooth transitions**: Uses `Curves.easeInOut` for natural feel

## 🎯 Usage Examples

### Basic Usage
```dart
ImprovedSubstanceCard(
  substance: substance,
  user: currentUser,
  onTap: () => calculateDosage(substance),
)
```

### Responsive Grid
```dart
ResponsiveSubstanceCardGrid(
  substances: popularSubstances,
  user: currentUser,
  onCardTap: (substance) => showDosageCalculation(substance),
)
```

### Demo Access
In debug mode, access the demo from Menu → "Improved Cards Demo"

## 🧪 Testing

### Test Coverage
- **Widget tests**: Verify UI structure and content
- **Responsive tests**: Check layout behavior on different screen sizes
- **Calculation tests**: Verify dosage calculations (normal dose, optional dose)
- **Color mapping tests**: Ensure substance-specific colors work correctly
- **Danger level tests**: Verify risk level mapping

### Running Tests
```bash
flutter test test/widgets/improved_substance_card_test.dart
flutter test test/verification/requirements_verification_test.dart
```

## 🎨 Design Specifications

### Colors
- **Background gradient**: `Colors.white.withOpacity(0.15)` to `Colors.white.withOpacity(0.05)`
- **Border**: Substance color with 30% opacity, 1.2px width
- **Shadow**: Neon glow with substance color, 20px blur radius
- **Text**: High contrast with proper opacity levels

### Typography
- **Substance name**: 20px, FontWeight.w800, substance color
- **Details**: 12px, FontWeight.w500, 70% opacity
- **Dosage**: 16px, FontWeight.w800, amber color
- **Labels**: 9px, FontWeight.w500, 54% opacity

### Spacing
- **Card padding**: 16px all around
- **Element spacing**: 8-12px between elements
- **Button height**: 36px
- **Icon size**: 48px container with 24px icon

## 🚀 Performance Optimizations

### Efficient Rendering
- **Minimal rebuilds**: Uses `AnimatedBuilder` only where needed
- **Cached animations**: Reuses animation controllers
- **Optimized shadows**: Uses efficient `BoxShadow` configurations

### Memory Management
- **Proper disposal**: All animation controllers are disposed
- **Efficient widgets**: Uses `const` constructors where possible
- **Minimal state**: Keeps widget state minimal

## 📚 Dependencies

### Required Models
- `DosageCalculatorSubstance`
- `DosageCalculatorUser`
- `DosageIntensity` enum

### Required Utilities
- `AppIconGenerator` - For substance icons
- `DesignTokens` - For color schemes
- `Spacing` - For consistent spacing

## 🎯 Future Enhancements

### Potential Improvements
1. **Enhanced animations**: Add entrance animations
2. **Accessibility**: Improve screen reader support
3. **Customization**: Allow theme customization
4. **Performance**: Add scroll-based virtualization for large lists
5. **Interactions**: Add drag-and-drop functionality

### Extensibility
- **Custom substances**: Easy to add new substance types
- **Theme support**: Can be extended for different color schemes
- **Layout options**: Can support different card sizes and layouts

## 📖 References

- **Demo UI**: Based on `demo_ui.html` design
- **Flutter docs**: [flutter.dev](https://flutter.dev)
- **Glassmorphism**: Modern UI design trend with translucent effects
- **Neon effects**: Glowing border and shadow effects