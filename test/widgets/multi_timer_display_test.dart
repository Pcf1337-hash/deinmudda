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

    test('tile width calculation should be narrower after changes', () {
      // Test the new calculation logic: 30% of screen width, clamped to 110-150px
      const double screenWidth400 = 400.0;
      const double screenWidth600 = 600.0;
      const double screenWidth320 = 320.0;
      
      // New calculation
      final newWidth400 = (screenWidth400 * 0.3).clamp(110.0, 150.0);
      final newWidth600 = (screenWidth600 * 0.3).clamp(110.0, 150.0);
      final newWidth320 = (screenWidth320 * 0.3).clamp(110.0, 150.0);
      
      // Verify the new tile widths
      expect(newWidth400, equals(120.0)); // 400 * 0.3 = 120
      expect(newWidth600, equals(150.0)); // 600 * 0.3 = 180, clamped to 150
      expect(newWidth320, equals(110.0)); // 320 * 0.3 = 96, clamped to 110
      
      // Verify they are smaller than the old calculation (40% screen width, 140-180px)
      final oldWidth400 = (screenWidth400 * 0.4).clamp(140.0, 180.0); // 160
      final oldWidth600 = (screenWidth600 * 0.4).clamp(140.0, 180.0); // 180
      final oldWidth320 = (screenWidth320 * 0.4).clamp(140.0, 180.0); // 140
      
      expect(newWidth400, lessThan(oldWidth400), reason: 'New tiles should be narrower on 400px screen');
      expect(newWidth600, lessThan(oldWidth600), reason: 'New tiles should be narrower on 600px screen');
      expect(newWidth320, lessThan(oldWidth320), reason: 'New tiles should be narrower on 320px screen');
      
      // Verify the percentage reduction
      final reduction400 = ((oldWidth400 - newWidth400) / oldWidth400 * 100);
      final reduction600 = ((oldWidth600 - newWidth600) / oldWidth600 * 100);
      final reduction320 = ((oldWidth320 - newWidth320) / oldWidth320 * 100);
      
      expect(reduction400, equals(25.0), reason: '25% reduction for 400px screen: from 160px to 120px');
      expect(reduction600, closeTo(16.7, 0.1), reason: '~16.7% reduction for 600px screen: from 180px to 150px');
      expect(reduction320, closeTo(21.4, 0.1), reason: '~21.4% reduction for 320px screen: from 140px to 110px');
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