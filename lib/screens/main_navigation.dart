import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../utils/platform_helper.dart';
import '../services/psychedelic_theme_service.dart';

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
    
    // Update system UI overlay style based on theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSystemUIOverlayStyle();
    });
  }

  void _updateSystemUIOverlayStyle() {
    if (!mounted) return;
    
    try {
      final psychedelicService = Provider.of<PsychedelicThemeService>(context, listen: false);
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      
      SystemChrome.setSystemUIOverlayStyle(
        PlatformHelper.getStatusBarStyle(
          isDark: isDark,
          isPsychedelicMode: psychedelicService.isPsychedelicMode,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Fehler beim Aktualisieren des SystemUIOverlayStyle: $e');
      }
    }
  }

  @override
  void dispose() {
    try {
      _pageController.dispose();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Fehler beim Dispose des PageController: $e');
      }
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (!mounted) return;
    
    try {
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
        
        // Platform-specific haptic feedback
        PlatformHelper.performHapticFeedback(HapticFeedbackType.selectionClick);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Fehler beim Navigieren zu Tab $index: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<PsychedelicThemeService>(
      builder: (context, psychedelicService, child) {
        // Update system UI overlay style when theme changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateSystemUIOverlayStyle();
        });
        
        return Scaffold(
          body: SafeArea(
            bottom: false, // Let bottom navigation handle its own safe area
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                
                // Platform-specific haptic feedback for swipe navigation
                PlatformHelper.performHapticFeedback(HapticFeedbackType.selectionClick);
              },
              // Use platform-appropriate scroll physics
              physics: PlatformHelper.isIOS 
                ? const BouncingScrollPhysics()
                : const ClampingScrollPhysics(),
              children: _screens,
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context, isDark),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : DesignTokens.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? DesignTokens.shadowDark.withOpacity(0.2)
                : DesignTokens.shadowLight.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = index == _currentIndex;

              return _buildNavigationItem(
                context,
                isDark,
                item,
                isActive,
                () => _onItemTapped(index),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    bool isDark,
    NavigationItem item,
    bool isActive,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: PerformanceHelper.getAnimationDuration(DesignTokens.animationMedium),
        curve: DesignTokens.curveEaseOut,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? DesignTokens.primaryIndigo.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: Spacing.borderRadiusLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: PerformanceHelper.getAnimationDuration(DesignTokens.animationFast),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                color: isActive
                    ? DesignTokens.primaryIndigo
                    : (isDark
                        ? DesignTokens.iconSecondaryDark
                        : DesignTokens.iconSecondaryLight),
                size: Spacing.iconMd,
              ),
            ),
            Spacing.verticalSpaceXs,
            AnimatedDefaultTextStyle(
              duration: PerformanceHelper.getAnimationDuration(DesignTokens.animationFast),
              style: theme.textTheme.labelSmall!.copyWith(
                color: isActive
                    ? DesignTokens.primaryIndigo
                    : (isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}