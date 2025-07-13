import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../widgets/theme_switcher.dart';
import '../widgets/reflective_app_bar_logo.dart';
import '../widgets/enhanced_bottom_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final themeService = ThemeService();
  await themeService.init();
  
  runApp(TestApp(themeService: themeService));
}

class TestApp extends StatelessWidget {
  final ThemeService themeService;
  
  const TestApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeService>.value(
      value: themeService,
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Theme Test',
            theme: themeService.getThemeData(),
            home: const TestScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _currentIndex = 0;
  
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    NavigationItem(
      icon: Icons.calculate_outlined,
      activeIcon: Icons.calculate,
      label: 'Calculator',
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Analytics',
    ),
    NavigationItem(
      icon: Icons.menu_outlined,
      activeIcon: Icons.menu,
      label: 'Menu',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const ReflectiveAppBarLogo(),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Theme Switcher Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ThemeSwitcher(),
                    const SizedBox(height: 16),
                    Text(
                      'Current Theme: ${themeService.themeDisplayName}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Enhanced Bottom Navigation Test',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: EnhancedBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _navigationItems,
        isTrippyMode: themeService.isTrippyDarkMode,
      ),
    );
  }
}