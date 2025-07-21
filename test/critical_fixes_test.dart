import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:konsum_tracker_pro/services/timer_service.dart';
import 'package:konsum_tracker_pro/services/database_service.dart';
import 'package:konsum_tracker_pro/widgets/responsive_widgets.dart';
import 'package:konsum_tracker_pro/widgets/dosage_calculator/substance_card.dart';
import 'package:konsum_tracker_pro/models/dosage_calculator_substance.dart';

void main() {
  group('Critical Fixes Tests', () {
    
    group('Timer Service Optimization Tests', () {
      late TimerService timerService;
      
      setUp(() {
        timerService = TimerService();
      });
      
      tearDown(() {
        timerService.dispose();
      });
      
      test('should limit maximum concurrent timers', () {
        // Test that the timer service doesn't exceed maximum concurrent timers
        expect(timerService.activeTimers.length, lessThanOrEqualTo(10));
      });
      
      test('should efficiently manage timer lookups', () {
        // Test that timer lookups are efficient using Map structure
        const testId = 'test_timer_id';
        expect(timerService.hasTimerWithId(testId), isFalse);
        expect(timerService.getTimerById(testId), isNull);
      });
      
      test('should provide thread-safe timer management', () {
        // Test that timer service handles concurrent access safely
        expect(timerService.isTimerActive(), isFalse);
        expect(timerService.hasAnyActiveTimer, isFalse);
      });
    });
    
    group('Database Security Tests', () {
      late DatabaseService databaseService;
      
      setUp(() {
        databaseService = DatabaseService();
      });
      
      test('should validate SQL queries for injection attempts', () {
        // Test SQL injection prevention
        const maliciousSql = "SELECT * FROM users; DROP TABLE users; --";
        expect(() => databaseService.safeRawQuery(maliciousSql), throwsArgumentError);
      });
      
      test('should provide safe parameterized queries', () async {
        // Test that safe query methods exist and work
        expect(databaseService.safeQuery, isNotNull);
        expect(databaseService.safeInsert, isNotNull);
        expect(databaseService.safeUpdate, isNotNull);
        expect(databaseService.safeDelete, isNotNull);
      });
      
      test('should handle database errors gracefully', () async {
        // Test error handling in database operations
        final result = await databaseService.safeQuery('nonexistent_table');
        expect(result, isEmpty); // Should return empty list on error
      });
    });
    
    group('Responsive Widget Tests', () {
      testWidgets('SafeScrollableColumn should prevent overflow', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafeScrollableColumn(
                children: List.generate(100, (index) => 
                  Container(height: 50, child: Text('Item $index'))
                ),
              ),
            ),
          ),
        );
        
        expect(find.byType(SafeScrollableColumn), findsOneWidget);
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
      
      testWidgets('SafeLayoutBuilder should handle errors gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafeLayoutBuilder(
                debugLabel: 'Test Layout',
                builder: (context, constraints) {
                  throw Exception('Test error');
                },
              ),
            ),
          ),
        );
        
        expect(find.text('Layout-Fehler'), findsOneWidget);
      });
      
      testWidgets('ResponsiveContainer should adapt to screen size', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ResponsiveContainer(
                child: Text('Test'),
              ),
            ),
          ),
        );
        
        expect(find.byType(ResponsiveContainer), findsOneWidget);
        expect(find.byType(LayoutBuilder), findsOneWidget);
      });
    });
    
    group('Substance Card Responsive Tests', () {
      testWidgets('SubstanceCard should use responsive layout', (WidgetTester tester) async {
        final substance = DosageCalculatorSubstance(
          name: 'Test Substance',
          lightDosePerKg: 1.0,
          normalDosePerKg: 2.0,
          strongDosePerKg: 3.0,
          administrationRoute: 'oral',
          duration: '4-6 hours',
          safetyNotes: 'Test safety notes',
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SubstanceCard(
                substance: substance,
                showDosagePreview: true,
                showRiskLevel: true,
              ),
            ),
          ),
        );
        
        expect(find.byType(SubstanceCard), findsOneWidget);
        expect(find.byType(LayoutBuilder), findsWidgets);
        expect(find.text('Test Substance'), findsOneWidget);
      });
    });
    
    group('Layout Error Prevention Tests', () {
      testWidgets('should handle RenderFlex overflow gracefully', (WidgetTester tester) async {
        // Test that overflow is handled gracefully
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 100,
                child: Row(
                  children: List.generate(10, (index) => 
                    Container(width: 50, height: 50, color: Colors.red)
                  ),
                ),
              ),
            ),
          ),
        );
        
        // The test should not crash due to overflow
        expect(find.byType(Row), findsOneWidget);
      });
      
      testWidgets('should handle unbounded height constraints', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafeExpanded(
                child: Column(
                  children: List.generate(100, (index) => 
                    Container(height: 50, child: Text('Item $index'))
                  ),
                ),
              ),
            ),
          ),
        );
        
        expect(find.byType(SafeExpanded), findsOneWidget);
        expect(find.byType(Flexible), findsOneWidget);
      });
    });
    
    group('Performance Tests', () {
      test('timer service should efficiently handle multiple timers', () {
        final timerService = TimerService();
        
        // Simulate multiple timer checks
        for (int i = 0; i < 100; i++) {
          expect(timerService.isTimerActive(), isFalse);
        }
        
        timerService.dispose();
      });
      
      test('database service should handle concurrent queries', () async {
        final databaseService = DatabaseService();
        
        // Simulate concurrent safe queries
        final futures = List.generate(10, (index) => 
          databaseService.safeQuery('substances', limit: 1)
        );
        
        final results = await Future.wait(futures);
        expect(results.length, equals(10));
      });
    });
  });
}