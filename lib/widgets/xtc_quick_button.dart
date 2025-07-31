import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../screens/quick_entry/xtc_entry_dialog.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../../widgets/glass_card.dart';

/// Quick button widget for XTC/Ecstasy entry
/// 
/// This provides a specialized quick entry button that opens
/// the XTC entry dialog with all specific fields.
class XTCQuickButton extends StatelessWidget {
  final VoidCallback? onEntryCreated;

  const XTCQuickButton({
    super.key,
    this.onEntryCreated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      onTap: () => _showXTCDialog(context),
      child: Container(
        height: 100,
        padding: Spacing.paddingMd,
        child: Row(
          children: [
            // XTC Icon with gradient background
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DesignTokens.accentPink.withOpacity(0.8),
                    DesignTokens.accentPink.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.accentPink.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.medication_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'XTC / Ecstasy',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : DesignTokens.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MDMA, MDA, Amph.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: DesignTokens.accentPink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Form, Farbe, Inhalt erfassen',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: (isDark ? Colors.white : DesignTokens.textDark)
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow indicator
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DesignTokens.accentPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: DesignTokens.accentPink,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
    ).slideX(
      begin: 0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Future<void> _showXTCDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const XTCEntryDialog(),
    );

    if (result == true && onEntryCreated != null) {
      onEntryCreated!();
    }
  }
}

/// Widget that provides multiple XTC-related quick actions
class XTCQuickButtonSection extends StatelessWidget {
  final VoidCallback? onEntryCreated;

  const XTCQuickButtonSection({
    super.key,
    this.onEntryCreated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'XTC / Ecstasy',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: DesignTokens.accentPink,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Spezialisierte Erfassung für Ecstasy-Pillen',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 100),
        ),
        
        const SizedBox(height: 16),
        
        XTCQuickButton(onEntryCreated: onEntryCreated).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 200),
        ),
        
        const SizedBox(height: 12),
        
        // Additional info card
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: DesignTokens.infoBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'XTC-Einträge erscheinen nicht in der Substanzverwaltung',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: DesignTokens.infoBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}

/// Compact XTC quick button for use in lists or grids
class CompactXTCQuickButton extends StatelessWidget {
  final VoidCallback? onEntryCreated;

  const CompactXTCQuickButton({
    super.key,
    this.onEntryCreated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      onTap: () => _showXTCDialog(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DesignTokens.accentPink.withOpacity(0.8),
                    DesignTokens.accentPink.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.accentPink.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.medication_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'XTC',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: DesignTokens.accentPink,
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              'Ecstasy',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
    ).scale(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1.0, 1.0),
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Future<void> _showXTCDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const XTCEntryDialog(),
    );

    if (result == true && onEntryCreated != null) {
      onEntryCreated!();
    }
  }
}