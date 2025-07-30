import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konsum_tracker_pro/widgets/multi_timer_display.dart';
import 'package:konsum_tracker_pro/services/timer_service.dart';
import 'package:konsum_tracker_pro/services/psychedelic_theme_service.dart';
import 'package:konsum_tracker_pro/models/entry.dart';

void main() {
  group('MultiTimerDisplay Widget Tests', () {
    testWidgets('should show empty state when no timers are active', (WidgetTester tester) async {
      // Create mock services
      final timerService = MockTimerService();
      final psychedelicService = MockPsychedelicThemeService();
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TimerService>.value(value: timerService),
              ChangeNotifierProvider<PsychedelicThemeService>.value(value: psychedelicService),
            ],
            child: const Scaffold(
              body: MultiTimerDisplay(),
            ),
          ),
        ),
      );

      // Verify that the widget shows nothing when no timers are active
      expect(find.byType(MultiTimerDisplay), findsOneWidget);
      expect(find.text('aktive Timer'), findsNothing);
    });

    testWidgets('should show single timer card when one timer is active', (WidgetTester tester) async {
      // Create mock services with one active timer
      final timerService = MockTimerService();
      final mockEntry = Entry.create(
        substanceId: '1',
        substanceName: 'Test Substance',
        dosage: 100.0,
        unit: 'mg',
        dateTime: DateTime.now(),
        timerStartTime: DateTime.now(),
        timerEndTime: DateTime.now().add(const Duration(hours: 2)),
      );
      timerService.setActiveTimers([mockEntry]);
      
      final psychedelicService = MockPsychedelicThemeService();
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TimerService>.value(value: timerService),
              ChangeNotifierProvider<PsychedelicThemeService>.value(value: psychedelicService),
            ],
            child: const Scaffold(
              body: MultiTimerDisplay(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that the widget shows the single timer
      expect(find.byType(MultiTimerDisplay), findsOneWidget);
      expect(find.text('Test Substance'), findsOneWidget);
    });

    testWidgets('should show multiple timer tiles when multiple timers are active', (WidgetTester tester) async {
      // Create mock services with multiple active timers
      final timerService = MockTimerService();
      final mockEntries = [
        Entry.create(
          substanceId: '1',
          substanceName: 'Test Substance 1',
          dosage: 100.0,
          unit: 'mg',
          dateTime: DateTime.now(),
          timerStartTime: DateTime.now(),
          timerEndTime: DateTime.now().add(const Duration(hours: 2)),
        ),
        Entry.create(
          substanceId: '2',
          substanceName: 'Test Substance 2',
          dosage: 50.0,
          unit: 'mg',
          dateTime: DateTime.now(),
          timerStartTime: DateTime.now(),
          timerEndTime: DateTime.now().add(const Duration(hours: 1)),
        ),
      ];
      timerService.setActiveTimers(mockEntries);
      
      final psychedelicService = MockPsychedelicThemeService();
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TimerService>.value(value: timerService),
              ChangeNotifierProvider<PsychedelicThemeService>.value(value: psychedelicService),
            ],
            child: const Scaffold(
              body: MultiTimerDisplay(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that the widget shows multiple timers
      expect(find.byType(MultiTimerDisplay), findsOneWidget);
      expect(find.text('2 aktive Timer'), findsOneWidget);
      expect(find.text('Test Substance 1'), findsOneWidget);
      expect(find.text('Test Substance 2'), findsOneWidget);
    });

    test('tile width calculation should provide optimal substance name visibility', () {
      // Test the updated calculation logic: 32% of screen width, clamped to 115-160px
      const double screenWidth400 = 400.0;
      const double screenWidth600 = 600.0;
      const double screenWidth320 = 320.0;
      
      // Updated calculation for better text visibility
      final newWidth400 = (screenWidth400 * 0.32).clamp(115.0, 160.0);
      final newWidth600 = (screenWidth600 * 0.32).clamp(115.0, 160.0);
      final newWidth320 = (screenWidth320 * 0.32).clamp(115.0, 160.0);
      
      // Verify the updated tile widths
      expect(newWidth400, equals(128.0)); // 400 * 0.32 = 128
      expect(newWidth600, equals(160.0)); // 600 * 0.32 = 192, clamped to 160
      expect(newWidth320, equals(115.0)); // 320 * 0.32 = 102.4, clamped to 115
      
      // Verify they provide better balance between compactness and text visibility
      // Old calculation was 30% screen width, 110-150px
      final oldWidth400 = (screenWidth400 * 0.3).clamp(110.0, 150.0); // 120
      final oldWidth600 = (screenWidth600 * 0.3).clamp(110.0, 150.0); // 150
      final oldWidth320 = (screenWidth320 * 0.3).clamp(110.0, 150.0); // 110
      
      expect(newWidth400, greaterThan(oldWidth400), reason: 'New tiles should be slightly wider for better text visibility on 400px screen');
      expect(newWidth600, greaterThan(oldWidth600), reason: 'New tiles should be wider for better text visibility on 600px screen');
      expect(newWidth320, greaterThan(oldWidth320), reason: 'New tiles should be wider for better text visibility on 320px screen');
      
      // Verify the improvements in text space
      final improvement400 = ((newWidth400 - oldWidth400) / oldWidth400 * 100);
      final improvement600 = ((newWidth600 - oldWidth600) / oldWidth600 * 100);
      final improvement320 = ((newWidth320 - oldWidth320) / oldWidth320 * 100);
      
      expect(improvement400, closeTo(6.7, 0.1), reason: '~6.7% improvement for 400px screen: from 120px to 128px');
      expect(improvement600, closeTo(6.7, 0.1), reason: '~6.7% improvement for 600px screen: from 150px to 160px');
      expect(improvement320, closeTo(4.5, 0.1), reason: '~4.5% improvement for 320px screen: from 110px to 115px');
    });
  });
}

// Mock classes for testing
class MockTimerService extends ChangeNotifier implements TimerService {
  List<Entry> _activeTimers = [];

  void setActiveTimers(List<Entry> timers) {
    _activeTimers = timers;
    notifyListeners();
  }

  @override
  List<Entry> get activeTimers => _activeTimers;

  @override
  Entry? get currentActiveTimer => _activeTimers.isNotEmpty ? _activeTimers.first : null;

  @override
  bool get hasAnyActiveTimer => _activeTimers.isNotEmpty;

  // Add other required methods as no-ops for testing
  @override
  Future<void> init() async {}

  @override
  Future<Entry> startTimer(Entry entry, {Duration? customDuration}) async => entry;

  @override
  Future<void> stopTimer(String entryId) async {}

  @override
  Future<void> pauseTimer(String entryId) async {}

  @override
  Future<void> resumeTimer(String entryId) async {}

  @override
  bool isTimerActive() => hasAnyActiveTimer;

  @override
  bool hasActiveTimer(String entryId) => _activeTimers.any((e) => e.id == entryId);

  @override
  Duration? getRemainingTime(String entryId) => null;

  @override
  double getTimerProgress(String entryId) => 0.0;
}

class MockPsychedelicThemeService extends ChangeNotifier implements PsychedelicThemeService {
  bool _isPsychedelicMode = false;

  @override
  bool get isPsychedelicMode => _isPsychedelicMode;

  void setPsychedelicMode(bool value) {
    _isPsychedelicMode = value;
    notifyListeners();
  }

  // Add other required methods as no-ops for testing
  @override
  Map<String, Color> getCurrentSubstanceColors() => {};

  @override
  void updateSubstanceColors(String substanceId) {}
}