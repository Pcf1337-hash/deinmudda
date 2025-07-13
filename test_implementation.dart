import 'dart:io';

void main() {
  print('Testing HomeScreen implementation...\n');
  
  // Test 1: Check if required files exist
  print('Test 1: Required files exist');
  final requiredFiles = [
    'lib/screens/home_screen.dart',
    'lib/widgets/active_timer_bar.dart',
    'lib/widgets/speed_dial.dart',
    'lib/services/timer_service.dart',
  ];
  
  for (final file in requiredFiles) {
    final exists = File(file).existsSync();
    print('  $file: ${exists ? "✓" : "✗"}');
  }
  print('');
  
  // Test 2: Check if imports are correct
  print('Test 2: Basic import structure');
  final homeScreenFile = File('lib/screens/home_screen.dart');
  if (homeScreenFile.existsSync()) {
    final content = homeScreenFile.readAsStringSync();
    final requiredImports = [
      'active_timer_bar.dart',
      'speed_dial.dart',
      'timer_service.dart',
    ];
    
    for (final import in requiredImports) {
      final hasImport = content.contains(import);
      print('  $import: ${hasImport ? "✓" : "✗"}');
    }
  }
  print('');
  
  // Test 3: Check if removed sections are gone
  print('Test 3: Removed sections');
  final homeScreenFile2 = File('lib/screens/home_screen.dart');
  if (homeScreenFile2.existsSync()) {
    final content = homeScreenFile2.readAsStringSync();
    final removedSections = [
      '_buildQuickActionsSection',
      '_buildAdvancedFeaturesSection',
      '_buildQuickActionCard',
    ];
    
    for (final section in removedSections) {
      final hasSection = content.contains(section);
      print('  $section removed: ${!hasSection ? "✓" : "✗"}');
    }
  }
  print('');
  
  // Test 4: Check if new features exist
  print('Test 4: New features added');
  final homeScreenFile3 = File('lib/screens/home_screen.dart');
  if (homeScreenFile3.existsSync()) {
    final content = homeScreenFile3.readAsStringSync();
    final newFeatures = [
      'ActiveTimerBar',
      'SpeedDial',
      '_activeTimer',
      '_stopActiveTimer',
      '_loadActiveTimer',
    ];
    
    for (final feature in newFeatures) {
      final hasFeature = content.contains(feature);
      print('  $feature: ${hasFeature ? "✓" : "✗"}');
    }
  }
  print('');
  
  // Test 5: Check TimerService modifications
  print('Test 5: TimerService modifications');
  final timerServiceFile = File('lib/services/timer_service.dart');
  if (timerServiceFile.existsSync()) {
    final content = timerServiceFile.readAsStringSync();
    final modifications = [
      'currentActiveTimer',
      'hasAnyActiveTimer',
      'Stop any existing active timer first',
    ];
    
    for (final mod in modifications) {
      final hasMod = content.contains(mod);
      print('  $mod: ${hasMod ? "✓" : "✗"}');
    }
  }
  print('');
  
  print('Implementation tests completed!');
}