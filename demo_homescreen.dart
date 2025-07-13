import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'lib/theme/design_tokens.dart';
import 'lib/theme/spacing.dart';
import 'lib/widgets/speed_dial.dart';
import 'lib/widgets/active_timer_bar.dart';
import 'lib/models/entry.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeScreen Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreenDemo(),
    );
  }
}

class HomeScreenDemo extends StatefulWidget {
  const HomeScreenDemo({super.key});

  @override
  State<HomeScreenDemo> createState() => _HomeScreenDemoState();
}

class _HomeScreenDemoState extends State<HomeScreenDemo> {
  Entry? _activeTimer;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeScreen Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Implementation Summary:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            const Text('✅ Removed Schnellaktionen section'),
            const Text('✅ Removed Erweiterte Funktionen section'),
            const Text('✅ Removed specific buttons (Neuer Eintrag, Quick Buttons verwalten, etc.)'),
            const Text('✅ Added ActiveTimerBar (shown only when timer is active)'),
            const Text('✅ Replaced FloatingActionButton with SpeedDial'),
            const Text('✅ SpeedDial includes "Neuer Eintrag" and "Timer stoppen"'),
            const Text('✅ Modified QuickEntry to automatically start timers'),
            const Text('✅ Ensured only one timer can be active at a time'),
            const Text('✅ Added proper error handling with addPostFrameCallback'),
            const Text('✅ Uses substance duration with fallback to 4 hours'),
            
            const SizedBox(height: 24),
            
            const Text(
              'New Components Created:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            const Text('• ActiveTimerBar widget'),
            const Text('• SpeedDial widget'),
            const Text('• Enhanced TimerService with single-timer constraint'),
            const Text('• Updated HomeScreen with timer integration'),
            
            const SizedBox(height: 24),
            
            const Text(
              'Demo ActiveTimerBar:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Demo ActiveTimerBar - this would require proper Entry model
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ActiveTimerBar would appear here when a timer is active\n'
                'Shows substance name, remaining time, and progress bar\n'
                'Animated with pulsing effect for visual feedback',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            
            const SizedBox(height: 80), // Space for SpeedDial
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        tooltip: 'Demo Actions',
        backgroundColor: Colors.pink,
        actions: [
          SpeedDialAction(
            child: const Icon(Icons.add_rounded),
            label: 'Neuer Eintrag',
            tooltip: 'Neuen Eintrag hinzufügen',
            backgroundColor: Colors.indigo,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Neuer Eintrag pressed')),
              );
            },
          ),
          SpeedDialAction(
            child: const Icon(Icons.timer_off_rounded),
            label: 'Timer stoppen',
            tooltip: 'Aktiven Timer stoppen',
            backgroundColor: Colors.orange,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Timer stoppen pressed')),
              );
            },
          ),
        ],
        child: const Icon(Icons.speed_rounded),
      ),
    );
  }
}