import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/design_tokens.dart';

enum ThemeMode3 {
  light,
  dark, 
  trippyDark,
}

class ThemeService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  
  ThemeMode3 _themeMode = ThemeMode3.dark; // Default to dark mode
  SharedPreferences? _prefs;
  
  ThemeMode3 get themeMode => _themeMode;
  
  bool get isLightMode => _themeMode == ThemeMode3.light;
  bool get isDarkMode => _themeMode == ThemeMode3.dark;
  bool get isTrippyDarkMode => _themeMode == ThemeMode3.trippyDark;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    final themeModeIndex = _prefs?.getInt(_themeModeKey) ?? 1; // Default to dark
    _themeMode = ThemeMode3.values[themeModeIndex.clamp(0, ThemeMode3.values.length - 1)];
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode3 mode) async {
    _themeMode = mode;
    await _prefs?.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }
  
  Future<void> cycleThemeMode() async {
    switch (_themeMode) {
      case ThemeMode3.light:
        await setThemeMode(ThemeMode3.dark);
        break;
      case ThemeMode3.dark:
        await setThemeMode(ThemeMode3.trippyDark);
        break;
      case ThemeMode3.trippyDark:
        await setThemeMode(ThemeMode3.light);
        break;
    }
  }
  
  // Get theme name for display
  String get themeDisplayName {
    switch (_themeMode) {
      case ThemeMode3.light:
        return 'Light Mode';
      case ThemeMode3.dark:
        return 'Dark Mode';
      case ThemeMode3.trippyDark:
        return 'Trippy Dark Mode';
    }
  }
  
  // Get theme icon for display
  IconData get themeIcon {
    switch (_themeMode) {
      case ThemeMode3.light:
        return Icons.light_mode;
      case ThemeMode3.dark:
        return Icons.dark_mode;
      case ThemeMode3.trippyDark:
        return Icons.auto_awesome;
    }
  }
  
  // Get appropriate theme data
  ThemeData getThemeData() {
    switch (_themeMode) {
      case ThemeMode3.light:
        return _getLightTheme();
      case ThemeMode3.dark:
        return _getDarkTheme();
      case ThemeMode3.trippyDark:
        return _getTrippyDarkTheme();
    }
  }
  
  ThemeData _getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DesignTokens.primaryIndigo,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: DesignTokens.backgroundLight,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: DesignTokens.textPrimaryLight,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DesignTokens.surfaceLight,
        selectedItemColor: DesignTokens.primaryIndigo,
        unselectedItemColor: DesignTokens.neutral500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: DesignTokens.surfaceLight,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: DesignTokens.textPrimaryLight,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: DesignTokens.textPrimaryLight,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: DesignTokens.textSecondaryLight,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: DesignTokens.textSecondaryLight,
        ),
      ),
    );
  }
  
  ThemeData _getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DesignTokens.primaryIndigo,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: DesignTokens.backgroundDark,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: DesignTokens.textPrimaryDark,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DesignTokens.surfaceDark,
        selectedItemColor: DesignTokens.primaryIndigo,
        unselectedItemColor: DesignTokens.neutral500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: DesignTokens.surfaceDark,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: DesignTokens.textPrimaryDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: DesignTokens.textPrimaryDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: DesignTokens.textSecondaryDark,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: DesignTokens.textSecondaryDark,
        ),
      ),
    );
  }
  
  ThemeData _getTrippyDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DesignTokens.neonPink,
        brightness: Brightness.dark,
        background: DesignTokens.psychedelicBackground,
        surface: DesignTokens.psychedelicSurface,
        surfaceVariant: DesignTokens.psychedelicSurfaceVariant,
        primary: DesignTokens.neonPink,
        secondary: DesignTokens.neonCyan,
        tertiary: DesignTokens.electricBlue,
        onBackground: DesignTokens.textPsychedelicPrimary,
        onSurface: DesignTokens.textPsychedelicPrimary,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onTertiary: Colors.black,
        outline: DesignTokens.psychedelicGlassBorder,
      ),
      scaffoldBackgroundColor: DesignTokens.psychedelicBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: DesignTokens.textPsychedelicPrimary,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DesignTokens.psychedelicSurface,
        selectedItemColor: DesignTokens.neonPink,
        unselectedItemColor: DesignTokens.textPsychedelicTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: DesignTokens.psychedelicSurface,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: DesignTokens.textPsychedelicPrimary,
          shadows: [
            Shadow(
              color: DesignTokens.psychedelicGlowPurple,
              blurRadius: 5,
            ),
          ],
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: DesignTokens.textPsychedelicPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: DesignTokens.textPsychedelicSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: DesignTokens.textPsychedelicSecondary,
        ),
      ),
    );
  }
}