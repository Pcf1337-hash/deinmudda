import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/entry.dart';
import '../interfaces/service_interfaces.dart';
import '../services/psychedelic_theme_service.dart';
import '../widgets/countdown_timer_widget.dart';
import '../widgets/active_timer_bar.dart';
import '../utils/safe_navigation.dart';
import '../../test/mocks/service_mocks.dart';

/// Test app to verify timer fixes work correctly
class TimerTestApp extends StatefulWidget {
  const TimerTestApp({super.key});

  @override
  State<TimerTestApp> createState() => _TimerTestAppState();
}

class _TimerTestAppState extends State<TimerTestApp> {
  final ITimerService _timerService = MockTimerService();
  late Entry _testEntry;
  bool _isTimerActive = false;

  @override
  void initState() {
    super.initState();
    _createTestEntry();
  }

  void _createTestEntry() {
    final now = DateTime.now();
    _testEntry = Entry(
      id: 'test-timer-001',
      substanceId: 'test-substance',
      substanceName: 'Test Substance (Long Name That Should Not Overflow)',
      dosage: 100.0,
      unit: 'mg',
      dateTime: now,
      cost: 10.0,
      notes: 'Test timer entry',
      createdAt: now,
      updatedAt: now,
      // Timer fields
      timerStartTime: now,
      timerEndTime: now.add(const Duration(minutes: 5)),
      timerCompleted: false,
      timerNotificationSent: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer Test App',
      theme: ThemeData(useMaterial3: true),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
          Provider(create: (_) => _timerService),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Timer Test'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _resetTest,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Timer Widget Tests',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Test 1: CountdownTimerWidget
                const Text('Test 1: CountdownTimerWidget'),
                CountdownTimerWidget(
                  endTime: DateTime.now().add(const Duration(minutes: 2)),
                  title: 'Test Countdown Timer with Very Long Title That Should Not Overflow',
                  onComplete: () {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Timer completed successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Test 2: ActiveTimerBar
                const Text('Test 2: ActiveTimerBar'),
                if (_isTimerActive)
                  ActiveTimerBar(
                    timer: _testEntry,
                    onTap: () {
                      if (mounted) {
                        SafeNavigation.showDialogSafe(
                          context,
                          AlertDialog(
                            title: const Text('Timer Tapped'),
                            content: const Text('Active timer bar tap works!'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                
                const SizedBox(height: 24),
                
                // Test Controls
                const Text('Test Controls'),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _startTimer,
                      child: const Text('Start Timer'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _stopTimer,
                      child: const Text('Stop Timer'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Test Results
                const Text('Test Results:'),
                Text('Timer Active: $_isTimerActive'),
                Text('Entry ID: ${_testEntry.id}'),
                Text('Remaining Time: ${_testEntry.formattedRemainingTime}'),
                Text('Progress: ${(_testEntry.timerProgress * 100).toStringAsFixed(1)}%'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startTimer() async {
    try {
      final updatedEntry = await _timerService.startTimer(_testEntry);
      if (mounted) {
        setState(() {
          _testEntry = updatedEntry;
          _isTimerActive = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting timer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _stopTimer() async {
    try {
      await _timerService.stopTimer(_testEntry.id);
      if (mounted) {
        setState(() {
          _isTimerActive = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping timer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetTest() {
    if (mounted) {
      setState(() {
        _createTestEntry();
        _isTimerActive = false;
      });
    }
  }

  @override
  void dispose() {
    _timerService.dispose();
    super.dispose();
  }
}

void main() {
  runApp(const TimerTestApp());
}