import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lib/screens/home_screen.dart';
import 'lib/interfaces/service_interfaces.dart';
import 'lib/services/psychedelic_theme_service.dart';
import 'test/mocks/service_mocks.dart';

/// Demo app to test the AnimatedSwitcher overflow fix
/// This simulates the home screen with various loading states
void main() {
  runApp(const AnimatedSwitcherTestApp());
}

class AnimatedSwitcherTestApp extends StatelessWidget {
  const AnimatedSwitcherTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnimatedSwitcher Overflow Test',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: MultiProvider(
        providers: [
          Provider<IEntryService>(create: (_) => MockEntryService()),
          Provider<IQuickButtonService>(create: (_) => MockQuickButtonService()),
          Provider<ITimerService>(create: (_) => MockTimerService()),
          Provider<ISubstanceService>(create: (_) => MockSubstanceService()),
          ChangeNotifierProvider<PsychedelicThemeService>(
            create: (_) => PsychedelicThemeService(),
          ),
        ],
        child: const TestHomePage(),
      ),
    );
  }
}

class TestHomePage extends StatefulWidget {
  const TestHomePage({super.key});

  @override
  State<TestHomePage> createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage> {
  bool _isDarkMode = false;
  bool _isTrippyMode = false;
  String _selectedScreenSize = 'Normal (375x667)';

  final Map<String, Size> _screenSizes = {
    'Small (320x480)': const Size(320, 480),
    'Normal (375x667)': const Size(375, 667),
    'Large (428x926)': const Size(428, 926),
    'Galaxy S10 (360x760)': const Size(360, 760),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnimatedSwitcher Overflow Test'),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
          IconButton(
            icon: Icon(_isTrippyMode ? Icons.psychology_alt : Icons.psychology),
            onPressed: () {
              setState(() {
                _isTrippyMode = !_isTrippyMode;
              });
              Provider.of<PsychedelicThemeService>(context, listen: false)
                  .togglePsychedelicMode();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Screen Size: '),
                    DropdownButton<String>(
                      value: _selectedScreenSize,
                      items: _screenSizes.keys.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedScreenSize = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _isDarkMode,
                      onChanged: (bool? value) {
                        setState(() {
                          _isDarkMode = value ?? false;
                        });
                      },
                    ),
                    const Text('Dark Mode'),
                    const SizedBox(width: 20),
                    Checkbox(
                      value: _isTrippyMode,
                      onChanged: (bool? value) {
                        setState(() {
                          _isTrippyMode = value ?? false;
                        });
                        Provider.of<PsychedelicThemeService>(context, listen: false)
                            .togglePsychedelicMode();
                      },
                    ),
                    const Text('Trippy Mode'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Simulated home screen container
          Expanded(
            child: Container(
              width: _screenSizes[_selectedScreenSize]!.width,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Theme(
                  data: _isDarkMode 
                      ? ThemeData.dark() 
                      : ThemeData.light(),
                  child: Container(
                    color: _isDarkMode ? Colors.black : Colors.white,
                    child: const HomeScreen(),
                  ),
                ),
              ),
            ),
          ),
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Test Instructions:\n'
              '1. Try different screen sizes to test responsive behavior\n'
              '2. Toggle Dark/Trippy modes to test theming\n'
              '3. Watch for any overflow errors during transitions\n'
              '4. Check that QuickEntry loads smoothly without layout issues',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}