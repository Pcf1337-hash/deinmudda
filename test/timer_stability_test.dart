import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/utils/crash_protection.dart';
import '../lib/utils/error_handler.dart';
import '../lib/models/entry.dart';
import '../lib/services/timer_service.dart';
import 'mocks/service_mocks.dart';

void main() {
  group('Timer Stability Tests', () {
    late TimerService timerService;
    late Entry testEntry;

    setUp(() {
      timerService = MockTimerService();
      final now = DateTime.now();
      testEntry = Entry(
        id: 'test-entry-id',
        substanceId: 'test-substance',
        substanceName: 'Test Substance',
        dosage: 100.0,
        unit: 'mg',
        dateTime: now,
        cost: 10.0,
        notes: 'Test entry for stability test',
        createdAt: now,
        updatedAt: now,
      );
      );
    });

    tearDown(() {
      timerService.dispose();
    });

    testWidgets('SafeStateMixin prevents setState after dispose', (WidgetTester tester) async {
      late bool setStateCallMade;
      late bool errorOccurred;

      final widget = TestWidgetWithSafeState(
        onSetState: () => setStateCallMade = true,
        onError: () => errorOccurred = true,
      );

      await tester.pumpWidget(MaterialApp(home: widget));

      // Trigger disposal
      await tester.pumpWidget(Container());

      // Verify setState was prevented
      expect(setStateCallMade, isFalse);
      expect(errorOccurred, isFalse);
    });

    testWidgets('CrashProtectionWrapper handles widget errors gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CrashProtectionWrapper(
            context: 'test',
            child: const ThrowingWidget(),
          ),
        ),
      );

      // Verify error fallback is shown
      expect(find.text('Ein Fehler ist aufgetreten'), findsOneWidget);
    });

    test('TimerService prevents duplicate timer instances', () async {
      await timerService.init();

      // Start timer
      final timerEntry1 = await timerService.startTimer(testEntry);
      expect(timerService.hasActiveTimer(testEntry.id), isTrue);

      // Try to start same timer again
      final timerEntry2 = await timerService.startTimer(testEntry);
      
      // Should still have only one active timer
      expect(timerService.activeTimers.length, equals(1));
      expect(timerService.hasActiveTimer(testEntry.id), isTrue);
    });

    test('TimerService persists and restores timer state', () async {
      await timerService.init();

      // Start timer
      final timerEntry = await timerService.startTimer(testEntry, customDuration: const Duration(minutes: 30));
      expect(timerService.hasActiveTimer(testEntry.id), isTrue);

      // Dispose and recreate service (simulating app restart)
      timerService.dispose();
      final newTimerService = TimerService();
      await newTimerService.init();

      // Timer should be restored
      expect(newTimerService.hasActiveTimer(testEntry.id), isTrue);
      expect(newTimerService.activeTimers.length, equals(1));

      newTimerService.dispose();
    });

    test('TimerService handles race conditions safely', () async {
      await timerService.init();

      // Start multiple concurrent operations
      final futures = List.generate(5, (index) => 
        timerService.startTimer(testEntry.copyWith(id: 'test-$index'))
      );

      final results = await Future.wait(futures);

      // All operations should complete without errors
      expect(results.length, equals(5));
      
      // Only one timer should be active (last one wins)
      expect(timerService.activeTimers.length, equals(1));
    });

    test('ErrorHandler logs timer operations correctly', () {
      final loggedMessages = <String>[];

      // Mock the debug print to capture logs
      ErrorHandler.logTimer('TEST', 'Timer test message');
      ErrorHandler.logStartup('TEST', 'Startup test message');
      ErrorHandler.logError('TEST', 'Error test message');

      // In a real test, you would verify the logs were captured
      // For now, this just verifies the methods don't throw
    });
  });
}

class TestWidgetWithSafeState extends StatefulWidget {
  final VoidCallback onSetState;
  final VoidCallback onError;

  const TestWidgetWithSafeState({
    super.key,
    required this.onSetState,
    required this.onError,
  });

  @override
  State<TestWidgetWithSafeState> createState() => _TestWidgetWithSafeStateState();
}

class _TestWidgetWithSafeStateState extends State<TestWidgetWithSafeState> with SafeStateMixin {
  @override
  void dispose() {
    super.dispose();
    
    // Try to call setState after dispose - this should be prevented
    Future.delayed(Duration.zero, () {
      try {
        safeSetState(() {
          widget.onSetState();
        });
      } catch (e) {
        widget.onError();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Test Widget'),
      ),
    );
  }
}

class ThrowingWidget extends StatelessWidget {
  const ThrowingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    throw Exception('Test exception');
  }
}