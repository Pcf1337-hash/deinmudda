import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'dosage_calculator/dosage_calculator_screen.dart'; // Changed from calendar_screen.dart
import 'menu_screen.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';
import '../widgets/layout_error_boundary.dart';
import '../utils/performance_helper.dart';
import '../utils/platform_helper.dart';
import '../utils/crash_protection.dart';
import '../utils/service_locator.dart';
import '../interfaces/service_interfaces.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with SafeStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late final IPsychedelicThemeService _psychedelicThemeService;

  final List<Widget> _screens = [
    const HomeScreen(key: ValueKey('home_screen')),
    const DosageCalculatorScreen(key: ValueKey('dosage_calculator_screen')), // Changed from CalendarScreen
    const StatisticsScreen(key: ValueKey('statistics_screen')),
    const MenuScreen(key: ValueKey('menu_screen')),
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
    _psychedelicThemeService = ServiceLocator.get<IPsychedelicThemeService>();
    
    // Update system UI overlay style based on theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSystemUIOverlayStyle();
    });
  }

  void _updateSystemUIOverlayStyle() {
    if (!mounted) return;
    
    try {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      
      SystemChrome.setSystemUIOverlayStyle(
        PlatformHelper.getStatusBarStyle(
          isDark: isDark,
          isPsychedelicMode: _psychedelicThemeService.isPsychedelicMode,
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
        safeSetState(() {
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

    return ListenableBuilder(
      listenable: _psychedelicThemeService,
      builder: (context, child) {
        // Update system UI overlay style when theme changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateSystemUIOverlayStyle();
        });
        
        return Scaffold(
          body: SafeArea(
            bottom: false, // Let bottom navigation handle its own safe area
            child: LayoutErrorBoundary(
              debugLabel: 'Main Navigation PageView',
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  if (!mounted) return;
                  safeSetState(() {
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
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context, isDark),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isDark) {
    // Use constant from Spacing to avoid potential accumulation issues
    // Store MediaQuery.of(context) in a variable to ensure consistent reference
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    
    // Clamp bottomPadding to prevent extreme values that could cause overflow
    final safeBottomPadding = bottomPadding.clamp(0.0, 50.0);
    final totalHeight = Spacing.bottomNavHeight + safeBottomPadding;
    
    return RepaintBoundary( // Wrap in RepaintBoundary to reduce unnecessary repaints
      child: Container(
        height: totalHeight,
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
                  index,
                  () => _onItemTapped(index),
                );
              }).toList(),
            ),
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
    int index,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return Flexible(
      child: RepaintBoundary( // Wrap each navigation item in RepaintBoundary
        child: AnimatedScale( // Use AnimatedScale instead of Transform.scale for better performance
          scale: isActive ? 1.05 : 1.0,
          duration: DesignTokens.animationFast,
          curve: DesignTokens.curveEaseOut,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: Spacing.sm,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? DesignTokens.primaryIndigo.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: Spacing.borderRadiusLg,
              ),
              child: SizedBox(
                height: 54, // Fixed height to prevent layout shifts
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Fixed size icon container to prevent scaling issues
                    SizedBox(
                      height: Spacing.iconMd + 4, // Fixed height for icon area
                      child: AnimatedSwitcher( // Smooth icon transitions
                        duration: DesignTokens.animationFast,
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          key: ValueKey('nav_icon_${index}_${isActive ? 'active' : 'inactive'}_${item.label}_${DateTime.now().millisecondsSinceEpoch}'),
                          color: isActive
                              ? DesignTokens.primaryIndigo
                              : (isDark
                                  ? DesignTokens.iconSecondaryDark
                                  : DesignTokens.iconSecondaryLight),
                          size: Spacing.iconMd,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2), // Fixed small spacing
                    // Fixed size text container to prevent scaling issues
                    SizedBox(
                      height: 14, // Fixed height for text area
                      child: AnimatedDefaultTextStyle( // Smooth text transitions
                        duration: DesignTokens.animationFast,
                        style: theme.textTheme.labelSmall!.copyWith(
                          color: isActive
                              ? DesignTokens.primaryIndigo
                              : (isDark
                                  ? DesignTokens.textSecondaryDark
                                  : DesignTokens.textSecondaryLight),
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 10,
                        ),
                        child: Text(
                          item.label,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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