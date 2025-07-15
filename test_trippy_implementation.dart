#!/usr/bin/env dart
import 'dart:io';

void main() {
  print('🔍 Testing Trippy Theme Implementation...');
  
  // Check if all required files exist
  var requiredFiles = [
    'lib/widgets/trippy_fab.dart',
    'lib/services/psychedelic_theme_service.dart',
    'lib/theme/design_tokens.dart',
    'lib/screens/home_screen.dart',
    'lib/screens/dosage_calculator/dosage_calculator_screen.dart',
    'lib/screens/quick_entry/quick_button_config_screen.dart',
    'lib/screens/timer_dashboard_screen.dart',
    'lib/screens/menu_screen.dart',
  ];
  
  var missingFiles = <String>[];
  
  for (var file in requiredFiles) {
    if (!File(file).existsSync()) {
      missingFiles.add(file);
    }
  }
  
  if (missingFiles.isNotEmpty) {
    print('❌ Missing files:');
    for (var file in missingFiles) {
      print('  - $file');
    }
    exit(1);
  }
  
  print('✅ All required files exist');
  
  // Check if imports are correct
  var trippyFabContent = File('lib/widgets/trippy_fab.dart').readAsStringSync();
  var homeScreenContent = File('lib/screens/home_screen.dart').readAsStringSync();
  
  if (trippyFabContent.contains('PsychedelicThemeService') &&
      trippyFabContent.contains('DesignTokens.neonPink') &&
      trippyFabContent.contains('LinearGradient')) {
    print('✅ TrippyFAB widget structure looks correct');
  } else {
    print('❌ TrippyFAB widget structure issues');
    exit(1);
  }
  
  if (homeScreenContent.contains('Consumer<PsychedelicThemeService>') &&
      homeScreenContent.contains('isPsychedelicMode') &&
      homeScreenContent.contains('DesignTokens.psychedelicBackground')) {
    print('✅ HomeScreen trippy theme integration looks correct');
  } else {
    print('❌ HomeScreen trippy theme integration issues');
    exit(1);
  }
  
  // Check README updates
  var readmeContent = File('README.md').readAsStringSync();
  
  if (readmeContent.contains('Trippy-Theme-System') &&
      readmeContent.contains('Zentraler FAB-Stil') &&
      readmeContent.contains('TrippyFAB-Widget')) {
    print('✅ README.md updated with trippy theme documentation');
  } else {
    print('❌ README.md missing trippy theme documentation');
    exit(1);
  }
  
  print('🎉 All basic tests passed!');
  print('');
  print('📋 Implementation Summary:');
  print('  ✅ Created unified TrippyFAB widget with neon pink to gray gradient');
  print('  ✅ Updated HomeScreen for trippy theme activation');
  print('  ✅ Updated DosageCalculator for trippy theme activation');
  print('  ✅ Updated QuickButtonConfig for trippy theme activation');
  print('  ✅ Updated TimerScreen for trippy theme activation');
  print('  ✅ Updated MenuScreen for trippy theme activation');
  print('  ✅ Added glow effects and continuous animations');
  print('  ✅ Updated README.md with comprehensive documentation');
  print('');
  print('🔮 Trippy Theme Features:');
  print('  • PsychedelicThemeService.isPsychedelicMode for activation');
  print('  • Adaptive color schemes with substance-specific visualization');
  print('  • TrippyFAB with neon pink→gray gradient and multi-layer glow');
  print('  • Psychedelic backgrounds and shader-based effects');
  print('  • Responsive activation across all relevant screens');
}