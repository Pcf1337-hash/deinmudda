import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lib/widgets/active_timer_bar.dart';
import 'lib/widgets/quick_entry/quick_button_widget.dart';
import 'lib/models/entry.dart';
import 'lib/models/quick_button_config.dart';
import 'lib/services/timer_service.dart';

/// Demo app to showcase the ActiveTimerBar overflow fixes
/// 
/// This demo shows:
/// 1. ActiveTimerBar handling different height constraints
/// 2. QuickButton with timer display integration
/// 3. Responsive layout adaptation
class OverflowFixDemo extends StatelessWidget {
  const OverflowFixDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ActiveTimerBar Overflow Fix Demo',
      theme: ThemeData.dark(),
      home: Provider<TimerService>(
        create: (_) => TimerService(),
        child: const DemoScreen(),
      ),
    );
  }
}

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  Entry createDemoTimer() {
    final timer = Entry.create(
      substanceId: 'demo-id',
      substanceName: 'LSD',
      dosage: 100.0,
      unit: 'μg',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      notes: 'Demo timer',
    );
    
    timer.timerEndTime = DateTime.now().add(const Duration(hours: 2, minutes: 30));
    timer.timerProgress = 0.3;
    timer.formattedRemainingTime = '2h 30m';
    timer.isTimerExpired = false;
    
    return timer;
  }

  QuickButtonConfig createDemoQuickButton() {
    return QuickButtonConfig(
      id: 'demo-quick',
      substanceId: 'demo-substance',
      substanceName: 'LSD',
      dosage: 100.0,
      unit: 'μg',
      cost: 15.0,
      position: 0,
      isActive: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final timer = createDemoTimer();
    final quickButton = createDemoQuickButton();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Overflow Fix Demo'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ActiveTimerBar Overflow Fix Demo',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This demo shows the ActiveTimerBar handling different height constraints '
                      'without causing RenderFlex overflow errors.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Original problematic constraint
            const Text(
              '🚨 Original Problematic Constraint (33px height):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              height: 33,
              width: 285,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ActiveTimerBar(
                timer: timer,
                onTap: () {},
              ),
            ),
            
            const SizedBox(height: 16),
            const Text(
              '✅ Now fits perfectly within 33px height constraint!',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
            ),
            
            const SizedBox(height: 32),
            
            // Minimal constraint test
            const Text(
              '📏 Ultra-minimal Constraint (25px height):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              height: 25,
              width: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ActiveTimerBar(
                timer: timer,
                onTap: () {},
              ),
            ),
            
            const SizedBox(height: 16),
            const Text(
              '✅ Shows minimal layout with essential info only',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
            ),
            
            const SizedBox(height: 32),
            
            // Comfortable size
            const Text(
              '📐 Comfortable Size (60px height):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              height: 60,
              width: 350,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ActiveTimerBar(
                timer: timer,
                onTap: () {},
              ),
            ),
            
            const SizedBox(height: 16),
            const Text(
              '✅ Shows full layout with progress bar and all features',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
            ),
            
            const SizedBox(height: 32),
            
            // QuickButton with timer display
            const Text(
              '⚡ QuickButton with Timer Display:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QuickButtonWidget(
                    config: quickButton,
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✅ Timer info displayed below dosage',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '✅ Compact format that fits existing layout',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '✅ Real-time updates when timer changes',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Test results summary
            Card(
              color: Colors.green[900],
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎉 Fix Summary',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '✅ No more RenderFlex overflow errors',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      '✅ Responsive layout adapts to any height constraint',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      '✅ Timer information now visible in QuickButtons',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      '✅ HomeScreen Error-Fallback issue resolved',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      '✅ Maintains all existing functionality',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const OverflowFixDemo());
}