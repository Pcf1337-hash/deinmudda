// This is a simple test to verify timer functionality
// Run this from the terminal with: dart test/timer_test.dart

import 'dart:async';
import '../lib/models/entry.dart';
import '../lib/models/substance.dart';
import '../lib/services/timer_service.dart';

void main() async {
  print('Testing timer functionality...');
  
  // Test 1: Test substance with duration
  print('\n1. Testing substance with duration...');
  final substance = Substance.create(
    name: 'Test Substance',
    category: SubstanceCategory.medication,
    defaultRiskLevel: RiskLevel.low,
    pricePerUnit: 1.0,
    defaultUnit: 'mg',
    duration: const Duration(seconds: 10), // 10 seconds for testing
  );
  
  print('Substance created: ${substance.name}, Duration: ${substance.formattedDuration}');
  
  // Test 2: Test entry with timer
  print('\n2. Testing entry with timer...');
  final now = DateTime.now();
  final entry = Entry.create(
    substanceId: substance.id,
    substanceName: substance.name,
    dosage: 100.0,
    unit: 'mg',
    dateTime: now,
    timerStartTime: now,
    timerEndTime: now.add(const Duration(seconds: 10)),
  );
  
  print('Entry created: ${entry.substanceName}');
  print('Timer active: ${entry.isTimerActive}');
  print('Timer progress: ${entry.timerProgress}');
  print('Remaining time: ${entry.formattedRemainingTime}');
  
  // Test 3: Test timer service parsing
  print('\n3. Testing timer service parsing...');
  final parsed1 = TimerService.parseDurationFromString('4–6 hours');
  final parsed2 = TimerService.parseDurationFromString('30–60 min');
  
  print('Parsed "4–6 hours": ${parsed1?.inHours}h');
  print('Parsed "30–60 min": ${parsed2?.inMinutes}min');
  
  // Test 4: Test timer progression
  print('\n4. Testing timer progression...');
  print('Initial remaining time: ${entry.formattedRemainingTime}');
  
  // Wait a bit and check again
  await Future.delayed(const Duration(seconds: 2));
  print('After 2 seconds: ${entry.formattedRemainingTime}');
  
  // Test 5: Test timer completion
  print('\n5. Testing timer completion...');
  await Future.delayed(const Duration(seconds: 9)); // Wait until timer expires
  print('Timer expired: ${entry.isTimerExpired}');
  
  print('\nTimer functionality test completed!');
}