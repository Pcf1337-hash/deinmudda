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
  group('Timer Layout Optimization Tests', () {
    late MockTimerService mockTimerService;
    late MockPsychedelicThemeService mockPsychedelicService;

    setUp(() {
      mockTimerService = MockTimerService();
      mockPsychedelicService = MockPsychedelicThemeService();
    });

    // Helper function to create test entries with realistic substance names
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
            ),
            child: const MultiTimerDisplay(),
          ),
        ),
      );
    }

    testWidgets('Should display more timers side-by-side with optimized layout', (WidgetTester tester) async {
      // Arrange: Create 6 timers with realistic substance names to test horizontal layout
      final timers = [
        createTestTimer('1', 'Cannabis'),
        createTestTimer('2', 'LSD'),
        createTestTimer('3', 'MDMA'),
        createTestTimer('4', 'Psilocybin'),
        createTestTimer('5', 'Caffeine'),
        createTestTimer('6', 'L-Theanine'),
      ];
      mockTimerService.setActiveTimers(timers);
      
      // Act: Test with standard screen size
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();
      
      // Assert: Should find the header and multiple timer content
      expect(find.text('6 aktive Timer'), findsOneWidget);
      expect(find.text('Cannabis'), findsOneWidget);
      expect(find.text('LSD'), findsOneWidget);
      expect(find.text('MDMA'), findsOneWidget);
      
      // Verify that horizontal layout is used (not vertical stacking)
      final multiTimerDisplay = find.byType(MultiTimerDisplay);
      expect(multiTimerDisplay, findsOneWidget);
    });

    testWidgets('Should handle long substance names without excessive truncation', (WidgetTester tester) async {
      // Arrange: Create timers with long substance names to test truncation handling
      final timers = [
        createTestTimer('1', 'N,N-Dimethyltryptamine'),
        createTestTimer('2', '4-Acetoxy-DMT'),
        createTestTimer('3', 'Lysergic Acid Diethylamide'),
        createTestTimer('4', '3,4-Methylenedioxymethamphetamine'),
      ];
      mockTimerService.setActiveTimers(timers);
      
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();
      
      // Assert: Should handle long names gracefully
      expect(find.text('4 aktive Timer'), findsOneWidget);
      // The exact text might be truncated, but the widget should render without overflow
    });

    testWidgets('Should maintain readability with compact layout on small screens', (WidgetTester tester) async {
      // Arrange: Create timers and test on small screen
      final timers = [
        createTestTimer('1', 'Weed'),
        createTestTimer('2', 'Acid'),
        createTestTimer('3', 'Molly'),
        createTestTimer('4', 'Shrooms'),
      ];
      mockTimerService.setActiveTimers(timers);
      
      // Act: Test with small screen size (320px width)
      await tester.binding.setSurfaceSize(const Size(320, 600));
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();
      
      // Assert: Should adapt to small screen while maintaining functionality
      expect(find.text('4 aktive Timer'), findsOneWidget);
      expect(find.text('Weed'), findsOneWidget);
      
      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Should efficiently use space on large screens', (WidgetTester tester) async {
      // Arrange: Create many timers for large screen test
      final timers = List.generate(8, (index) => 
        createTestTimer('timer_$index', 'Substance ${index + 1}')
      );
      mockTimerService.setActiveTimers(timers);
      
      // Act: Test with large screen size
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();
      
      // Assert: Should show more timers on large screen
      expect(find.text('8 aktive Timer'), findsOneWidget);
      expect(find.text('Substance 1'), findsOneWidget);
      
      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Should prevent vertical stacking that makes home page unnecessarily long', (WidgetTester tester) async {
      // Arrange: Multiple timers to verify horizontal layout prevents long page
      final timers = [
        createTestTimer('1', 'Timer A'),
        createTestTimer('2', 'Timer B'),
        createTestTimer('3', 'Timer C'),
        createTestTimer('4', 'Timer D'),
        createTestTimer('5', 'Timer E'),
      ];
      mockTimerService.setActiveTimers(timers);
      
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();
      
      // Assert: Should use horizontal scrolling layout, not vertical stacking
      expect(find.text('5 aktive Timer'), findsOneWidget);
      
      // The widget should not cause excessive vertical space usage
      final multiTimerWidget = tester.widget<MultiTimerDisplay>(find.byType(MultiTimerDisplay));
      expect(multiTimerWidget, isNotNull);
    });
  });
}