import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/psychedelic_theme_service.dart';
import '../theme/design_tokens.dart';
import '../widgets/glass_card.dart';
import '../widgets/pulsating_widgets.dart';

class PsychedelicSettingsScreen extends StatelessWidget {
  const PsychedelicSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Psychedelic Mode',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<PsychedelicThemeService>(
        builder: (context, psychedelicService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning Card
                _buildWarningCard(context, isDark),
                
                const SizedBox(height: 24),
                
                // Master Toggle
                _buildMasterToggleCard(context, psychedelicService, isDark),
                
                const SizedBox(height: 16),
                
                // Animation Settings
                _buildAnimationSettingsCard(context, psychedelicService, isDark),
                
                const SizedBox(height: 16),
                
                // Intensity Settings
                _buildIntensitySettingsCard(context, psychedelicService, isDark),
                
                const SizedBox(height: 16),
                
                // Substance Settings
                _buildSubstanceSettingsCard(context, psychedelicService, isDark),
                
                const SizedBox(height: 24),
                
                // Info Card
                _buildInfoCard(context, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context, bool isDark) {
    return PsychedelicGlassCard(
      glowColor: DesignTokens.neonMagenta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: DesignTokens.neonMagenta,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Wichtiger Hinweis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? DesignTokens.textPsychedelicPrimary : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Der Psychedelic Mode ist für verantwortungsvolle Nutzung unter medizinischer Begleitung konzipiert. Die Farben und Animationen sind für erweiterte Pupillen optimiert.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? DesignTokens.textPsychedelicSecondary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterToggleCard(
    BuildContext context,
    PsychedelicThemeService service,
    bool isDark,
  ) {
    return PsychedelicGlassCard(
      glowColor: service.isPsychedelicMode ? DesignTokens.neonPurple : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PulsatingIcon(
                icon: Icons.psychology_rounded,
                color: service.isPsychedelicMode 
                    ? DesignTokens.neonPurple 
                    : (isDark ? DesignTokens.textPsychedelicSecondary : null),
                isEnabled: service.isPsychedelicMode,
                glowColor: DesignTokens.neonPurple,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Psychedelic Mode',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? DesignTokens.textPsychedelicPrimary : null,
                  ),
                ),
              ),
              Switch(
                value: service.isPsychedelicMode,
                onChanged: (value) async {
                  await service.togglePsychedelicMode();
                },
                activeColor: DesignTokens.neonPurple,
                activeTrackColor: DesignTokens.neonPurple.withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            service.isPsychedelicMode 
                ? 'Psychedelic Mode ist aktiv - Optimiert für erweiterte Bewusstseinszustände'
                : 'Aktiviere den Psychedelic Mode für ein immersives Erlebnis',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? DesignTokens.textPsychedelicSecondary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationSettingsCard(
    BuildContext context,
    PsychedelicThemeService service,
    bool isDark,
  ) {
    return PsychedelicGlassCard(
      glowColor: service.isAnimatedBackgroundEnabled 
          ? DesignTokens.neonCyan 
          : DesignTokens.textPsychedelicTertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PulsatingIcon(
                icon: Icons.auto_awesome_rounded,
                color: service.isAnimatedBackgroundEnabled 
                    ? DesignTokens.neonCyan 
                    : (isDark ? DesignTokens.textPsychedelicSecondary : null),
                isEnabled: service.isAnimatedBackgroundEnabled && service.isPsychedelicMode,
                glowColor: DesignTokens.neonCyan,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Animationen',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? DesignTokens.textPsychedelicPrimary : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Animated Background Toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animierter Hintergrund',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark ? DesignTokens.textPsychedelicPrimary : null,
                      ),
                    ),
                    Text(
                      'Sanfte Wellenanimationen im Hintergrund',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? DesignTokens.textPsychedelicSecondary : null,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: service.isAnimatedBackgroundEnabled,
                onChanged: service.isPsychedelicMode 
                    ? (value) => service.setAnimatedBackground(value)
                    : null,
                activeColor: DesignTokens.neonCyan,
                activeTrackColor: DesignTokens.neonCyan.withOpacity(0.3),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Pulsing Buttons Toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pulsierende Buttons',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark ? DesignTokens.textPsychedelicPrimary : null,
                      ),
                    ),
                    Text(
                      'Wichtige Buttons pulsieren sanft',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? DesignTokens.textPsychedelicSecondary : null,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: service.isPulsingButtonsEnabled,
                onChanged: service.isPsychedelicMode 
                    ? (value) => service.setPulsingButtons(value)
                    : null,
                activeColor: DesignTokens.neonCyan,
                activeTrackColor: DesignTokens.neonCyan.withOpacity(0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntensitySettingsCard(
    BuildContext context,
    PsychedelicThemeService service,
    bool isDark,
  ) {
    return PsychedelicGlassCard(
      glowColor: DesignTokens.acidGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PulsatingIcon(
                icon: Icons.tune_rounded,
                color: DesignTokens.acidGreen,
                isEnabled: service.isPsychedelicMode,
                glowColor: DesignTokens.acidGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Intensität',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? DesignTokens.textPsychedelicPrimary : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Glow Intensity Slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Glow-Intensität: ${(service.glowIntensity * 100).round()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? DesignTokens.textPsychedelicPrimary : null,
                ),
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: DesignTokens.acidGreen,
                  thumbColor: DesignTokens.acidGreen,
                  overlayColor: DesignTokens.acidGreen.withOpacity(0.2),
                  inactiveTrackColor: DesignTokens.acidGreen.withOpacity(0.3),
                ),
                child: Slider(
                  value: service.glowIntensity,
                  min: 0.0,
                  max: 2.0,
                  divisions: 20,
                  onChanged: service.isPsychedelicMode 
                      ? (value) => service.setGlowIntensity(value)
                      : null,
                ),
              ),
              Text(
                'Niedrig = Subtil, Hoch = Intensiv',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? DesignTokens.textPsychedelicSecondary : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubstanceSettingsCard(
    BuildContext context,
    PsychedelicThemeService service,
    bool isDark,
  ) {
    final substanceColors = service.getCurrentSubstanceColors();
    
    return PsychedelicGlassCard(
      glowColor: substanceColors['primary'],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PulsatingIcon(
                icon: Icons.palette_rounded,
                color: substanceColors['primary'],
                isEnabled: service.isPsychedelicMode,
                glowColor: substanceColors['primary'],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Substanz-Farben',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? DesignTokens.textPsychedelicPrimary : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            'Aktuelle Substanz: ${_getSubstanceDisplayName(service.currentSubstance)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? DesignTokens.textPsychedelicPrimary : null,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Substance Color Grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSubstanceColorButton(context, service, 'lsd', 'LSD', DesignTokens.substanceLSD),
              _buildSubstanceColorButton(context, service, 'mdma', 'MDMA', DesignTokens.substanceMDMA),
              _buildSubstanceColorButton(context, service, 'cannabis', 'Cannabis', DesignTokens.substanceCannabis),
              _buildSubstanceColorButton(context, service, 'psilocybin', 'Psilocybin', DesignTokens.substancePsilocybin),
              _buildSubstanceColorButton(context, service, 'ketamine', 'Ketamine', DesignTokens.substanceKetamine),
              _buildSubstanceColorButton(context, service, 'default', 'Standard', DesignTokens.substanceDefault),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubstanceColorButton(
    BuildContext context,
    PsychedelicThemeService service,
    String substance,
    String displayName,
    Color color,
  ) {
    final isSelected = service.currentSubstance == substance;
    
    return GestureDetector(
      onTap: service.isPsychedelicMode 
          ? () => service.setCurrentSubstance(substance)
          : null,
      child: PulsatingWidget(
        isEnabled: isSelected && service.isPsychedelicMode,
        glowColor: color,
        intensity: 0.8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            displayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSelected ? color : color.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark) {
    return PsychedelicGlassCard(
      glowColor: DesignTokens.neonCyan,
      intensity: 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_rounded,
                color: DesignTokens.neonCyan,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Über Psychedelic Mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? DesignTokens.textPsychedelicPrimary : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Optimiert für erweiterte Pupillen\n'
            '• Reduzierter Blauanteil für Augenschonung\n'
            '• Sanfte Animationen für immersive Erfahrung\n'
            '• Substanz-spezifische Farbkodierung\n'
            '• 60fps Performance für flüssige Bedienung',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? DesignTokens.textPsychedelicSecondary : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getSubstanceDisplayName(String substance) {
    switch (substance) {
      case 'lsd':
        return 'LSD (Violett)';
      case 'mdma':
        return 'MDMA (Pink)';
      case 'cannabis':
        return 'Cannabis (Grün)';
      case 'psilocybin':
        return 'Psilocybin (Cyan)';
      case 'ketamine':
        return 'Ketamine (Blau)';
      default:
        return 'Standard (Violett)';
    }
  }
}