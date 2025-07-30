import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:konsum_tracker_pro/models/entry.dart';
import 'package:konsum_tracker_pro/services/timer_service.dart';
import 'package:konsum_tracker_pro/services/psychedelic_theme_service.dart';
import 'package:konsum_tracker_pro/widgets/multi_timer_display.dart';
import 'package:konsum_tracker_pro/interfaces/service_interfaces.dart';

// Mock services for testing
class MockTimerService extends ChangeNotifier implements ITimerService {
  List<Entry> _activeTimers = [];
  
  @override
  List<Entry> get activeTimers => _activeTimers;
  
  void setActiveTimers(List<Entry> timers) {
    _activeTimers = timers;
    notifyListeners();
  }
  
  @override
  Entry? get currentActiveTimer => _activeTimers.isNotEmpty ? _activeTimers.first : null;
  
  @override
  bool get hasActiveTimers => _activeTimers.isNotEmpty;
  
  @override
  bool isTimerActive(String entryId) => _activeTimers.any((t) => t.id == entryId);
  
  @override
  Entry? getTimerById(String entryId) => _activeTimers.where((t) => t.id == entryId).firstOrNull;
  
  // Mock implementations for interface compliance
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
  Future<void> refreshActiveTimers() async {}
  
  @override
  Future<Entry> updateTimerDuration(Entry entry, Duration newDuration) async => entry;
}

class MockPsychedelicThemeService extends ChangeNotifier {
  bool _isPsychedelicMode = false;
  
  bool get isPsychedelicMode => _isPsychedelicMode;
  
  void setPsychedelicMode(bool enabled) {
    _isPsychedelicMode = enabled;
    notifyListeners();
  }
  
  Map<String, Color> getCurrentSubstanceColors() {
    return {
      'primary': Colors.blue,
      'secondary': Colors.purple,
    };
  }
}

void main() {
  group('MultiTimerDisplay Multiple Timer Tests', () {
    late MockTimerService mockTimerService;
    late MockPsychedelicThemeService mockPsychedelicService;

    setUp(() {
      mockTimerService = MockTimerService();
      mockPsychedelicService = MockPsychedelicThemeService();
    });

    // Helper function to create test entries
    Entry createTestTimer(String id, String substanceName, {bool isActive = true, bool isExpired = false}) {
      final now = DateTime.now();
      return Entry.create(
        substanceId: id,
        substanceName: substanceName,
        dosage: 10.0,
        unit: 'mg',
        dateTime: now,
        notes: 'Test timer',
      ).copyWith(
        id: id,
        timerStartTime: now.subtract(const Duration(minutes: 30)),
        timerEndTime: isExpired 
            ? now.subtract(const Duration(minutes: 1)) // Expired timer
            : now.add(const Duration(hours: 1)), // Active timer
        timerCompleted: isExpired,
      );
    }

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider<ITimerService>.value(value: mockTimerService),
              ChangeNotifierProvider<PsychedelicThemeService>.value(value: mockPsychedelicService),
            ],
            child: const MultiTimerDisplay(),
          ),
        ),
      );
    }

    testWidgets('Should handle no active timers gracefully', (WidgetTester tester) async {
      // Arrange: No active timers
      mockTimerService.setActiveTimers([]);
      
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Assert: Widget should be hidden when no timers
      expect(find.byType(MultiTimerDisplay), findsOneWidget);
      // The actual content should be shrunk (SizedBox.shrink)
    });

    testWidgets('Should display single timer correctly', (WidgetTester tester) async {
      // Arrange: Single active timer
      final timer = createTestTimer('1', 'Caffeine');
      mockTimerService.setActiveTimers([timer]);
      
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Assert: Should find the timer content
      expect(find.text('Caffeine'), findsOneWidget);
    });

    testWidgets('Should display multiple timers without overflow', (WidgetTester tester) async {
      // Arrange: Multiple active timers
      final timers = [
        createTestTimer('1', 'Caffeine'),
        createTestTimer('2', 'L-Theanine'),
        createTestTimer('3', 'Vitamin D'),
        createTestTimer('4', 'Omega-3'),
        createTestTimer('5', 'Magnesium'),
      ];
      mockTimerService.setActiveTimers(timers);
      
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle(); // Wait for animations
      
      // Assert: Should find multiple timer tiles
      expect(find.text('5 aktive Timer'), findsOneWidget);
      expect(find.text('Caffeine'), findsOneWidget);
      expect(find.text('L-Theanine'), findsOneWidget);
      
      // Should not cause overflow errors
    });

    testWidgets('Should handle many concurrent timers efficiently', (WidgetTester tester) async {
      // Arrange: Maximum number of concurrent timers (stress test)
      final timers = List.generate(15, (index) => 
        createTestTimer('timer_$index', 'Substance ${index + 1}')
      );
      mockTimerService.setActiveTimers(timers);
      
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();
      
      // Assert: Should handle many timers without performance issues
      expect(find.text('15 aktive Timer'), findsOneWidget);
      
      // Should complete rendering within reasonable time
      // No overflow errors should occur
    });

    testWidgets('Should filter out expired timers automatically', (WidgetTester tester) async {
      // Arrange: Mix of active and expired timers
      final timers = [
        createTestTimer('1', 'Active Timer 1', isActive: true, isExpired: false),
        createTestTimer('2', 'Expired Timer', isActive: false, isExpired: true),
        createTestTimer('3', 'Active Timer 2', isActive: true, isExpired: false),
      ];
      mockTimerService.setActiveTimers(timers);
      
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();
      
      // Assert: Only active timers should be displayed
      expect(find.text('Active Timer 1'), findsOneWidget);
      expect(find.text('Active Timer 2'), findsOneWidget);
      expect(find.text('Expired Timer'), findsNothing);
      expect(find.text('2 aktive Timer'), findsOneWidget);
    });

    testWidgets('Should adapt layout for different screen sizes', (WidgetTester tester) async {
      // Arrange: Multiple timers
      final timers = [
        createTestTimer('1', 'Timer 1'),
        createTestTimer('2', 'Timer 2'),
        createTestTimer('3', 'Timer 3'),
      ];
      mockTimerService.setActiveTimers(timers);
      
      // Act: Test with smaller screen size
      await tester.binding.setSurfaceSize(const Size(300, 600));
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();
      
      // Assert: Should adapt to smaller screen
      expect(find.text('3 aktive Timer'), findsOneWidget);
      
      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Should handle psychedelic mode correctly', (WidgetTester tester) async {
      // Arrange: Multiple timers with psychedelic mode enabled
      final timers = [
        createTestTimer('1', 'Timer 1'),
        createTestTimer('2', 'Timer 2'),
      ];
      mockTimerService.setActiveTimers(timers);
      mockPsychedelicService.setPsychedelicMode(true);
      
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();
      
      // Assert: Should render in psychedelic mode without errors
      expect(find.text('2 aktive Timer'), findsOneWidget);
    });

    testWidgets('Should optimize animations for many timers', (WidgetTester tester) async {
      // Arrange: Many timers that should trigger animation optimization
      final timers = List.generate(8, (index) => 
        createTestTimer('timer_$index', 'Substance ${index + 1}')
      );
      mockTimerService.setActiveTimers(timers);
      
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100)); // Shorter animation time
      await tester.pumpAndSettle();
      
      // Assert: Should complete animations quickly for performance
      expect(find.text('8 aktive Timer'), findsOneWidget);
      
      // Animation should be optimized (faster/simpler) for many timers
    });
  });
}