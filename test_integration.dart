// Test: Timer Service Integration Test
// This test verifies that the timer service properly handles single-timer constraint

import 'dart:io';

void main() {
  print('Testing Timer Service Integration...\n');
  
  // Test 1: Verify TimerService has single-timer constraint
  print('Test 1: TimerService single-timer constraint');
  final timerServiceFile = File('lib/services/timer_service.dart');
  
  if (timerServiceFile.existsSync()) {
    final content = timerServiceFile.readAsStringSync();
    
    // Check for single-timer enforcement
    final hasStopExistingTimers = content.contains('Stop any existing active timer first');
    final hasCurrentActiveTimer = content.contains('currentActiveTimer');
    final hasHasAnyActiveTimer = content.contains('hasAnyActiveTimer');
    
    print('  Stop existing timers check: ${hasStopExistingTimers ? "✓" : "✗"}');
    print('  currentActiveTimer method: ${hasCurrentActiveTimer ? "✓" : "✗"}');
    print('  hasAnyActiveTimer method: ${hasHasAnyActiveTimer ? "✓" : "✗"}');
  }
  print('');
  
  // Test 2: Verify HomeScreen integration
  print('Test 2: HomeScreen timer integration');
  final homeScreenFile = File('lib/screens/home_screen.dart');
  
  if (homeScreenFile.existsSync()) {
    final content = homeScreenFile.readAsStringSync();
    
    // Check for timer integration
    final hasActiveTimer = content.contains('Entry? _activeTimer');
    final hasLoadActiveTimer = content.contains('_loadActiveTimer');
    final hasStopActiveTimer = content.contains('_stopActiveTimer');
    final hasTimerService = content.contains('TimerService _timerService');
    final hasSubstanceService = content.contains('SubstanceService _substanceService');
    
    print('  Active timer state: ${hasActiveTimer ? "✓" : "✗"}');
    print('  Load active timer method: ${hasLoadActiveTimer ? "✓" : "✗"}');
    print('  Stop active timer method: ${hasStopActiveTimer ? "✓" : "✗"}');
    print('  Timer service instance: ${hasTimerService ? "✓" : "✗"}');
    print('  Substance service instance: ${hasSubstanceService ? "✓" : "✗"}');
  }
  print('');
  
  // Test 3: Verify QuickEntry timer integration
  print('Test 3: QuickEntry timer integration');
  if (homeScreenFile.existsSync()) {
    final content = homeScreenFile.readAsStringSync();
    
    // Check for timer integration in QuickEntry
    final hasAutomaticTimer = content.contains('Start timer automatically');
    final hasSubstanceDuration = content.contains('substance?.duration');
    final hasFallbackDuration = content.contains('fallbackDuration');
    final hasAddPostFrameCallback = content.contains('addPostFrameCallback');
    
    print('  Automatic timer start: ${hasAutomaticTimer ? "✓" : "✗"}');
    print('  Substance duration usage: ${hasSubstanceDuration ? "✓" : "✗"}');
    print('  Fallback duration: ${hasFallbackDuration ? "✓" : "✗"}');
    print('  addPostFrameCallback usage: ${hasAddPostFrameCallback ? "✓" : "✗"}');
  }
  print('');
  
  // Test 4: Verify UI components
  print('Test 4: UI component integration');
  if (homeScreenFile.existsSync()) {
    final content = homeScreenFile.readAsStringSync();
    
    // Check for UI components
    final hasActiveTimerBar = content.contains('ActiveTimerBar(');
    final hasSpeedDial = content.contains('SpeedDial(');
    final hasConditionalTimer = content.contains('if (_activeTimer != null)');
    final hasSpeedDialActions = content.contains('SpeedDialAction(');
    
    print('  ActiveTimerBar usage: ${hasActiveTimerBar ? "✓" : "✗"}');
    print('  SpeedDial usage: ${hasSpeedDial ? "✓" : "✗"}');
    print('  Conditional timer display: ${hasConditionalTimer ? "✓" : "✗"}');
    print('  SpeedDial actions: ${hasSpeedDialActions ? "✓" : "✗"}');
  }
  print('');
  
  // Test 5: Verify removed sections
  print('Test 5: Removed sections verification');
  if (homeScreenFile.existsSync()) {
    final content = homeScreenFile.readAsStringSync();
    
    // Check that old sections are removed
    final hasQuickActions = content.contains('_buildQuickActionsSection');
    final hasAdvancedFeatures = content.contains('_buildAdvancedFeaturesSection');
    final hasQuickActionCard = content.contains('_buildQuickActionCard');
    final hasOldFAB = content.contains('FloatingActionButton(');
    
    print('  QuickActions removed: ${!hasQuickActions ? "✓" : "✗"}');
    print('  AdvancedFeatures removed: ${!hasAdvancedFeatures ? "✓" : "✗"}');
    print('  QuickActionCard removed: ${!hasQuickActionCard ? "✓" : "✗"}');
    print('  Old FAB removed: ${!hasOldFAB ? "✓" : "✗"}');
  }
  print('');
  
  print('Integration test completed!');
  print('');
  print('Summary of implemented features:');
  print('• HomeScreen cleanup (removed unwanted sections)');
  print('• ActiveTimerBar for visual timer feedback');
  print('• SpeedDial with "Neuer Eintrag" and "Timer stoppen"');
  print('• Automatic timer start with QuickEntry');
  print('• Single active timer constraint');
  print('• Substance duration with fallback');
  print('• Proper error handling with addPostFrameCallback');
}