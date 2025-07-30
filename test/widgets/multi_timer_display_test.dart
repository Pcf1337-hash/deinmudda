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