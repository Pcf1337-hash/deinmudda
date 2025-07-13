import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/design_tokens.dart';

class PsychedelicThemeService extends ChangeNotifier {
  static const String _psychedelicModeKey = 'psychedelic_mode';
  static const String _animatedBackgroundKey = 'animated_background';
  static const String _pulsingButtonsKey = 'pulsing_buttons';
  static const String _glowIntensityKey = 'glow_intensity';
  static const String _currentSubstanceKey = 'current_substance';
  
  bool _isPsychedelicMode = false;
  bool _isAnimatedBackgroundEnabled = true;
  bool _isPulsingButtonsEnabled = true;
  double _glowIntensity = 1.0;
  String _currentSubstance = 'default';
  
  SharedPreferences? _prefs;
  
  bool get isPsychedelicMode => _isPsychedelicMode;
  bool get isAnimatedBackgroundEnabled => _isAnimatedBackgroundEnabled;
  bool get isPulsingButtonsEnabled => _isPulsingButtonsEnabled;
  double get glowIntensity => _glowIntensity;
  String get currentSubstance => _currentSubstance;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    _isPsychedelicMode = _prefs?.getBool(_psychedelicModeKey) ?? false;
    _isAnimatedBackgroundEnabled = _prefs?.getBool(_animatedBackgroundKey) ?? true;
    _isPulsingButtonsEnabled = _prefs?.getBool(_pulsingButtonsKey) ?? true;
    _glowIntensity = _prefs?.getDouble(_glowIntensityKey) ?? 1.0;
    _currentSubstance = _prefs?.getString(_currentSubstanceKey) ?? 'default';
    notifyListeners();
  }
  
  Future<void> togglePsychedelicMode() async {
    _isPsychedelicMode = !_isPsychedelicMode;
    await _prefs?.setBool(_psychedelicModeKey, _isPsychedelicMode);
    notifyListeners();
  }
  
  Future<void> setAnimatedBackground(bool enabled) async {
    _isAnimatedBackgroundEnabled = enabled;
    await _prefs?.setBool(_animatedBackgroundKey, enabled);
    notifyListeners();
  }
  
  Future<void> setPulsingButtons(bool enabled) async {
    _isPulsingButtonsEnabled = enabled;
    await _prefs?.setBool(_pulsingButtonsKey, enabled);
    notifyListeners();
  }
  
  Future<void> setGlowIntensity(double intensity) async {
    _glowIntensity = intensity.clamp(0.0, 2.0);
    await _prefs?.setDouble(_glowIntensityKey, _glowIntensity);
    notifyListeners();
  }
  
  Future<void> setCurrentSubstance(String substance) async {
    _currentSubstance = substance;
    await _prefs?.setString(_currentSubstanceKey, substance);
    notifyListeners();
  }
  
  // Get current substance colors
  Map<String, Color> getCurrentSubstanceColors() {
    return DesignTokens.getSubstanceColor(_currentSubstance);
  }
  
  // Get appropriate theme based on settings
  ThemeData getTheme(bool isDark) {
    if (!isDark) {
      return ThemeData.light(); // Return light theme for light mode
    }
    
    if (_isPsychedelicMode) {
      return _buildPsychedelicTheme();
    }
    
    return ThemeData.dark(); // Return regular dark theme
  }
  
  ThemeData _buildPsychedelicTheme() {
    final substanceColors = getCurrentSubstanceColors();
    final primaryColor = substanceColors['primary'] ?? DesignTokens.neonPurple;
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        background: DesignTokens.psychedelicBackground,
        surface: DesignTokens.psychedelicSurface,
        surfaceVariant: DesignTokens.psychedelicSurfaceVariant,
        primary: primaryColor,
        secondary: DesignTokens.neonCyan,
        tertiary: DesignTokens.acidGreen,
        onBackground: DesignTokens.textPsychedelicPrimary,
        onSurface: DesignTokens.textPsychedelicPrimary,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onTertiary: Colors.black,
        outline: DesignTokens.psychedelicGlassBorder,
      ),
      scaffoldBackgroundColor: DesignTokens.psychedelicBackground,
      textTheme: _buildPsychedelicTextTheme(),
      elevatedButtonTheme: _buildPsychedelicElevatedButtonTheme(primaryColor),
      floatingActionButtonTheme: _buildPsychedelicFABTheme(primaryColor),
      bottomNavigationBarTheme: _buildPsychedelicBottomNavTheme(),
      appBarTheme: _buildPsychedelicAppBarTheme(),
      iconTheme: IconThemeData(
        color: DesignTokens.textPsychedelicPrimary,
        size: 24,
      ),
      primaryIconTheme: IconThemeData(
        color: primaryColor,
        size: 24,
      ),
      splashFactory: NoSplash.splashFactory, // Disable splash for psychedelic mode
    );
  }
  
  TextTheme _buildPsychedelicTextTheme() {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: DesignTokens.textPsychedelicPrimary,
        letterSpacing: -0.5,
        shadows: [
          Shadow(
            color: DesignTokens.psychedelicGlowPurple,
            blurRadius: 5,
          ),
        ],
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: DesignTokens.textPsychedelicPrimary,
        letterSpacing: -0.25,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: DesignTokens.textPsychedelicPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: DesignTokens.textPsychedelicPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: DesignTokens.textPsychedelicPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: DesignTokens.textPsychedelicPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: DesignTokens.textPsychedelicPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: DesignTokens.textPsychedelicPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: DesignTokens.textPsychedelicPrimary,
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
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: DesignTokens.textPsychedelicTertiary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: DesignTokens.textPsychedelicPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: DesignTokens.textPsychedelicSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: DesignTokens.textPsychedelicTertiary,
      ),
    );
  }
  
  ElevatedButtonThemeData _buildPsychedelicElevatedButtonTheme(Color primaryColor) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
      ),
    );
  }
  
  FloatingActionButtonThemeData _buildPsychedelicFABTheme(Color primaryColor) {
    return FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    );
  }
  
  BottomNavigationBarThemeData _buildPsychedelicBottomNavTheme() {
    return const BottomNavigationBarThemeData(
      backgroundColor: DesignTokens.psychedelicSurface,
      selectedItemColor: DesignTokens.neonPurple,
      unselectedItemColor: DesignTokens.textPsychedelicTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }
  
  AppBarTheme _buildPsychedelicAppBarTheme() {
    return const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: DesignTokens.textPsychedelicPrimary,
      iconTheme: IconThemeData(
        color: DesignTokens.textPsychedelicPrimary,
      ),
    );
  }
  
  // Helper method to get glow effect based on intensity
  BoxShadow getGlowEffect(Color color, {double radius = 20}) {
    return BoxShadow(
      color: color.withOpacity(0.3 * _glowIntensity),
      blurRadius: radius * _glowIntensity,
      spreadRadius: (radius * 0.2) * _glowIntensity,
    );
  }
  
  // Helper method to get multiple glow effects
  List<BoxShadow> getMultipleGlowEffects(Color color, {double radius = 20}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.3 * _glowIntensity),
        blurRadius: radius * _glowIntensity,
        spreadRadius: (radius * 0.2) * _glowIntensity,
      ),
      BoxShadow(
        color: color.withOpacity(0.1 * _glowIntensity),
        blurRadius: (radius * 2) * _glowIntensity,
        spreadRadius: (radius * 0.4) * _glowIntensity,
      ),
    ];
  }
}