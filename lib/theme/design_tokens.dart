import 'package:flutter/material.dart';

class DesignTokens {
  // Primary Colors
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  
  // Psychedelic Neon Colors
  static const Color neonPurple = Color(0xFF9D4EDD);
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color acidGreen = Color(0xFF39FF14);
  static const Color neonMagenta = Color(0xFFFF073A);
  static const Color neonPink = Color(0xFFFF10F0);
  static const Color electricBlue = Color(0xFF0080FF);
  static const Color laserGreen = Color(0xFF00FF41);
  
  // Substance-Specific Colors
  static const Color substanceLSD = Color(0xFF9D4EDD);      // Purple
  static const Color substanceMDMA = Color(0xFFFF10F0);     // Pink
  static const Color substanceCannabis = Color(0xFF39FF14); // Acid Green
  static const Color substancePsilocybin = Color(0xFF00F5FF); // Cyan
  static const Color substanceKetamine = Color(0xFF0080FF); // Electric Blue
  static const Color substanceDefault = Color(0xFF9D4EDD);  // Default Purple
  
  // Accent Colors
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPink = Color(0xFFFF10F0);
  
  // Neutral Colors - Light Theme
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);
  
  // Status Colors
  static const Color successGreen = Color(0xFF22C55E);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color warningYellow = Color(0xFFFBBF24);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);
  
  // Glass Effect Colors
  static const Color glassLight = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x1A000000);
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassBorderDark = Color(0x33000000);
  
  // Psychedelic Glass Effects
  static const Color psychedelicGlass = Color(0x0AFFFFFF);
  static const Color psychedelicGlassBorder = Color(0x22FFFFFF);
  static const Color psychedelicGlowPurple = Color(0x339D4EDD);
  static const Color psychedelicGlowCyan = Color(0x3300F5FF);
  static const Color psychedelicGlowGreen = Color(0x3339FF14);
  static const Color psychedelicGlowMagenta = Color(0x33FF073A);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryIndigo, primaryPurple],
  );
  
  // Psychedelic Gradients
  static const LinearGradient psychedelicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonPurple, neonCyan, acidGreen],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient psychedelicBackground1 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0A0A),
      Color(0xFF1A0A1A),
      Color(0xFF0A1A1A),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient psychedelicBackground2 = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF0A0A0A),
      Color(0xFF1A0A0A),
      Color(0xFF0A0A1A),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient neonGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x229D4EDD),
      Color(0x0A9D4EDD),
      Color(0x00000000),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentCyan, accentEmerald],
  );

  static const LinearGradient glassGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x20FFFFFF),
      Color(0x10FFFFFF),
    ],
  );

  static const LinearGradient glassGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x20FFFFFF),
      Color(0x05FFFFFF),
    ],
  );
  
  // Psychedelic Glass Gradients
  static const LinearGradient psychedelicGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x15FFFFFF),
      Color(0x08FFFFFF),
      Color(0x02FFFFFF),
    ],
  );
  
  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x40000000);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFBFBFB);
  static const Color backgroundDark = Color(0xFF0F0F0F);
  
  // Psychedelic Dark Mode Colors
  static const Color psychedelicBackground = Color(0xFF0A0A0A);
  static const Color psychedelicSurface = Color(0xFF080808);
  static const Color psychedelicSurfaceVariant = Color(0xFF1B1B1B);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);

  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);
  
  // Psychedelic Text Colors (reduced blue content)
  static const Color textPsychedelicPrimary = Color(0xFFFFFAFA);  // Slightly warm white
  static const Color textPsychedelicSecondary = Color(0xFFE5E5E5); // Warm gray
  static const Color textPsychedelicTertiary = Color(0xFFB8B8B8);  // Muted gray
  static const Color textPsychedelicAccent = Color(0xFF9D4EDD);    // Neon purple
  
  // Icon Colors
  static const Color iconPrimaryLight = Color(0xFF374151);
  static const Color iconSecondaryLight = Color(0xFF6B7280);
  
  static const Color iconPrimaryDark = Color(0xFFF3F4F6);
  static const Color iconSecondaryDark = Color(0xFF9CA3AF);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);
  
  // Divider Colors
  static const Color dividerLight = Color(0xFFF3F4F6);
  static const Color dividerDark = Color(0xFF1F2937);
  
  // Risk Level Colors
  static const Color riskLow = Color(0xFF22C55E);
  static const Color riskMedium = Color(0xFFF59E0B);
  static const Color riskHigh = Color(0xFFEF4444);
  static const Color riskCritical = Color(0xFF991B1B);
  
  // Category Colors
  static const Color categoryAlcohol = Color(0xFFDC2626);
  static const Color categoryTobacco = Color(0xFF7C2D12);
  static const Color categoryCannabis = Color(0xFF16A34A);
  static const Color categoryStimulants = Color(0xFFEA580C);
  static const Color categoryDepressants = Color(0xFF7C3AED);
  static const Color categoryHallucinogens = Color(0xFFDB2777);
  static const Color categoryOther = Color(0xFF6B7280);
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationExtraSlow = Duration(milliseconds: 800);
  
  // Psychedelic Animation Durations
  static const Duration pulseAnimation = Duration(milliseconds: 1500);
  static const Duration glowAnimation = Duration(milliseconds: 2000);
  static const Duration backgroundAnimation = Duration(milliseconds: 8000);
  static const Duration transitionAnimation = Duration(milliseconds: 400);

  // Animation Curves
  static const Curve curveDefault = Curves.easeInOutCubic;
  static const Curve curveEaseOut = Curves.easeOutCubic;
  static const Curve curveEaseIn = Curves.easeInCubic;
  static const Curve curveSpring = Curves.elasticOut;
  static const Curve curveBack = Curves.easeOutBack;
  
  // Psychedelic Animation Curves
  static const Curve curvePulse = Curves.easeInOutSine;
  static const Curve curveGlow = Curves.easeInOutQuad;
  static const Curve curveHypnotic = Curves.easeInOutCirc;
  
  // Substance Color Mapping
  static Map<String, Color> getSubstanceColor(String substance) {
    final substanceLower = substance.toLowerCase();
    
    if (substanceLower.contains('lsd') || substanceLower.contains('acid')) {
      return {'primary': substanceLSD, 'glow': psychedelicGlowPurple};
    } else if (substanceLower.contains('mdma') || substanceLower.contains('ecstasy')) {
      return {'primary': substanceMDMA, 'glow': psychedelicGlowMagenta};
    } else if (substanceLower.contains('cannabis') || substanceLower.contains('thc')) {
      return {'primary': substanceCannabis, 'glow': psychedelicGlowGreen};
    } else if (substanceLower.contains('psilocybin') || substanceLower.contains('mushroom')) {
      return {'primary': substancePsilocybin, 'glow': psychedelicGlowCyan};
    } else if (substanceLower.contains('ketamine') || substanceLower.contains('ket')) {
      return {'primary': substanceKetamine, 'glow': psychedelicGlowCyan};
    } else {
      return {'primary': substanceDefault, 'glow': psychedelicGlowPurple};
    }
  }
}
