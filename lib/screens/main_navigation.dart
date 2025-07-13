import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'dosage_calculator/dosage_calculator_screen.dart'; // Changed from calendar_screen.dart
import 'menu_screen.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';
import '../utils/performance_helper.dart';
import '../services/theme_service.dart';
import '../widgets/enhanced_bottom_navigation.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DosageCalculatorScreen(), // Changed from CalendarScreen
    const StatisticsScreen(),
    const MenuScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_rounded,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    NavigationItem(
      icon: Icons.calculate_outlined, // Changed from calendar_today_outlined
      activeIcon: Icons.calculate_rounded, // Changed from calendar_today_rounded
      label: 'Dosisrechner', // Changed from Kalender
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics_rounded,
      label: 'Statistiken',
    ),
    NavigationItem(
      icon: Icons.menu_rounded,
      activeIcon: Icons.menu_rounded,
      label: 'Menü',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        // Use optimized animation duration
        duration: PerformanceHelper.getAnimationDuration(DesignTokens.animationMedium),
        curve: DesignTokens.curveEaseOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // Disable swiping to reduce frame time errors
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: EnhancedBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: _navigationItems,
        isTrippyMode: themeService.isTrippyDarkMode,
      ),
    );
  }
}