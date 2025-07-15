import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lib/screens/dosage_calculator/dosage_calculator_screen.dart';
import 'lib/screens/timer_dashboard_screen.dart';
import 'lib/screens/settings_screen.dart';
import 'lib/services/psychedelic_theme_service.dart';
import 'lib/services/settings_service.dart';
import 'lib/services/database_service.dart';
import 'lib/models/substance.dart';
import 'lib/models/dosage_calculator_substance.dart';

void main() {
  runApp(const OverflowTestApp());
}

class OverflowTestApp extends StatelessWidget {
  const OverflowTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overflow Test App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          // Test with larger font sizes
          headlineLarge: TextStyle(fontSize: 32),
          headlineMedium: TextStyle(fontSize: 28),
          titleLarge: TextStyle(fontSize: 24),
          titleMedium: TextStyle(fontSize: 20),
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
          bodySmall: TextStyle(fontSize: 14),
        ),
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
          ChangeNotifierProvider(create: (_) => SettingsService()),
          ChangeNotifierProvider(create: (_) => DatabaseService()),
        ],
        child: const OverflowTestScreen(),
      ),
    );
  }
}

class OverflowTestScreen extends StatefulWidget {
  const OverflowTestScreen({super.key});

  @override
  State<OverflowTestScreen> createState() => _OverflowTestScreenState();
}

class _OverflowTestScreenState extends State<OverflowTestScreen> {
  int _selectedIndex = 0;
  double _textScale = 1.0;
  
  final List<Widget> _screens = [
    const DosageCalculatorScreen(),
    const TimerDashboardScreen(),
    const SettingsScreen(),
  ];

  final List<String> _screenNames = [
    'Dosage Calculator',
    'Timer Dashboard', 
    'Settings'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Overflow Test: ${_screenNames[_selectedIndex]}'),
        actions: [
          PopupMenuButton<double>(
            icon: const Icon(Icons.text_fields),
            onSelected: (scale) {
              setState(() {
                _textScale = scale;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1.0,
                child: Text('Normal (1.0x)'),
              ),
              const PopupMenuItem(
                value: 1.5,
                child: Text('Large (1.5x)'),
              ),
              const PopupMenuItem(
                value: 2.0,
                child: Text('Extra Large (2.0x)'),
              ),
              const PopupMenuItem(
                value: 3.0,
                child: Text('Accessibility (3.0x)'),
              ),
            ],
          ),
        ],
      ),
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(_textScale),
        ),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Dosage Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTestInfo,
        tooltip: 'Test Info',
        child: const Icon(Icons.info),
      ),
    );
  }

  void _showTestInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Overflow Test Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Text Scale: ${_textScale}x'),
              const SizedBox(height: 16),
              const Text('Test Scenarios:'),
              const SizedBox(height: 8),
              const Text('• Normal text scaling (1.0x)'),
              const Text('• Large text scaling (1.5x)'),
              const Text('• Extra large text scaling (2.0x)'),
              const Text('• Accessibility text scaling (3.0x)'),
              const SizedBox(height: 16),
              const Text('Features Being Tested:'),
              const SizedBox(height: 8),
              const Text('• Flexible container heights'),
              const Text('• FittedBox for text scaling'),
              const Text('• SingleChildScrollView for scrollable content'),
              const Text('• Responsive layout with LayoutBuilder'),
              const Text('• Text overflow prevention'),
              const SizedBox(height: 16),
              const Text('Expected Results:'),
              const SizedBox(height: 8),
              const Text('• No UI overflow errors'),
              const Text('• Proper text scaling'),
              const Text('• Scrollable content when needed'),
              const Text('• Responsive layout on different screen sizes'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Test widget with extreme content
class ExtremeContentTestWidget extends StatelessWidget {
  const ExtremeContentTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Extremely Long Title That Should Scale Down Properly'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Test card with very long substance name
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Methyl​enedioxy​methamphetamine (MDMA) - Very Long Chemical Name',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Flexible(
                      child: Text(
                        'This is a very long description that should wrap properly and not cause overflow. '
                        'It contains detailed information about the substance, its effects, duration, '
                        'and safety considerations. The text should be properly constrained and scrollable.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Button 1'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Button 2'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Button 3'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Test list with long items
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.science),
                  title: Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text('Very Long Substance Name That Should Scale $index'),
                    ),
                  ),
                  subtitle: const Flexible(
                    child: Text(
                      'This is a very long subtitle that should wrap properly and not cause overflow issues even on small screens with large text.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}