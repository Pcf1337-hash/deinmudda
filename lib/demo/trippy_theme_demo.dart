import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/psychedelic_theme_service.dart';
import '../widgets/trippy_fab.dart';
import '../theme/design_tokens.dart';

/// Demo screen showcasing the Trippy Theme functionality
class TrippyThemeDemo extends StatefulWidget {
  const TrippyThemeDemo({super.key});

  @override
  State<TrippyThemeDemo> createState() => _TrippyThemeDemoState();
}

class _TrippyThemeDemoState extends State<TrippyThemeDemo> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PsychedelicThemeService>(
      builder: (context, psychedelicService, child) {
        final isPsychedelicMode = psychedelicService.isPsychedelicMode;
        final substanceColors = psychedelicService.getCurrentSubstanceColors();
        
        return Scaffold(
          backgroundColor: isPsychedelicMode 
            ? DesignTokens.psychedelicBackground 
            : null,
          body: Container(
            decoration: isPsychedelicMode 
              ? const BoxDecoration(
                  gradient: DesignTokens.psychedelicBackground1,
                ) 
              : null,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Trippy Theme Demo',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: isPsychedelicMode 
                              ? DesignTokens.textPsychedelicPrimary 
                              : null,
                            shadows: isPsychedelicMode 
                              ? [
                                  Shadow(
                                    color: substanceColors['primary']!,
                                    blurRadius: 8,
                                  ),
                                ] 
                              : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Theme status
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isPsychedelicMode 
                          ? DesignTokens.psychedelicSurface.withOpacity(0.5)
                          : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: isPsychedelicMode 
                          ? Border.all(
                              color: substanceColors['primary']!.withOpacity(0.5),
                              width: 1,
                            )
                          : null,
                        boxShadow: isPsychedelicMode 
                          ? [
                              psychedelicService.getGlowEffect(
                                substanceColors['glow']!,
                                radius: 15,
                              ),
                            ]
                          : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme Status',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: isPsychedelicMode 
                                ? DesignTokens.textPsychedelicPrimary 
                                : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mode: ${isPsychedelicMode ? "🔮 Trippy" : "🌙 Standard"}',
                            style: TextStyle(
                              color: isPsychedelicMode 
                                ? DesignTokens.textPsychedelicSecondary 
                                : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            'Substance: ${psychedelicService.currentSubstance}',
                            style: TextStyle(
                              color: isPsychedelicMode 
                                ? DesignTokens.textPsychedelicSecondary 
                                : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            'Glow Intensity: ${(psychedelicService.glowIntensity * 100).toInt()}%',
                            style: TextStyle(
                              color: isPsychedelicMode 
                                ? DesignTokens.textPsychedelicSecondary 
                                : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Controls
                    Text(
                      'Controls',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isPsychedelicMode 
                          ? DesignTokens.textPsychedelicPrimary 
                          : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Toggle trippy mode
                    Card(
                      color: isPsychedelicMode 
                        ? DesignTokens.psychedelicSurface.withOpacity(0.3)
                        : null,
                      child: ListTile(
                        leading: Icon(
                          isPsychedelicMode ? Icons.psychology : Icons.psychology_outlined,
                          color: isPsychedelicMode 
                            ? substanceColors['primary']
                            : null,
                        ),
                        title: Text(
                          'Trippy Mode',
                          style: TextStyle(
                            color: isPsychedelicMode 
                              ? DesignTokens.textPsychedelicPrimary 
                              : null,
                          ),
                        ),
                        trailing: Switch(
                          value: isPsychedelicMode,
                          onChanged: (value) {
                            psychedelicService.togglePsychedelicMode();
                          },
                          activeColor: substanceColors['primary'],
                        ),
                      ),
                    ),
                    
                    // Glow intensity slider
                    Card(
                      color: isPsychedelicMode 
                        ? DesignTokens.psychedelicSurface.withOpacity(0.3)
                        : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Glow Intensity',
                              style: TextStyle(
                                color: isPsychedelicMode 
                                  ? DesignTokens.textPsychedelicPrimary 
                                  : null,
                              ),
                            ),
                            Slider(
                              value: psychedelicService.glowIntensity,
                              onChanged: (value) {
                                psychedelicService.setGlowIntensity(value);
                              },
                              min: 0.0,
                              max: 2.0,
                              divisions: 20,
                              label: '${(psychedelicService.glowIntensity * 100).toInt()}%',
                              activeColor: substanceColors['primary'],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Demo text
                    Center(
                      child: Text(
                        isPsychedelicMode 
                          ? '🔮 Trippy mode active!\nExperience the psychedelic interface.'
                          : 'Switch to trippy mode to see the\npsychedelic effects in action.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isPsychedelicMode 
                            ? DesignTokens.textPsychedelicSecondary 
                            : Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: TrippyFAB(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isPsychedelicMode 
                      ? '🔮 TrippyFAB activated!'
                      : 'Standard FAB mode',
                  ),
                  backgroundColor: isPsychedelicMode 
                    ? substanceColors['primary']
                    : null,
                ),
              );
            },
            icon: Icons.star,
            label: 'Demo Action',
            isExtended: true,
          ),
        );
      },
    );
  }
}