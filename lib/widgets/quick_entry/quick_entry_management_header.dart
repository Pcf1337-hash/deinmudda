import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';

/// Separated header widget for Quick Entry Management Screen
/// This helps break down the complexity by isolating the app bar logic
class QuickEntryManagementHeader extends StatelessWidget {
  final int quickButtonCount;
  final bool isReordering;
  final VoidCallback onBackPressed;
  final VoidCallback onReorderToggle;

  const QuickEntryManagementHeader({
    super.key,
    required this.quickButtonCount,
    required this.isReordering,
    required this.onBackPressed,
    required this.onReorderToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: _buildGradient(isDark),
      ),
      child: SafeArea(
        child: Padding(
          padding: Spacing.paddingMd,
          child: _buildHeaderContent(context, theme),
        ),
      ),
    );
  }

  BoxDecoration _buildGradient(bool isDark) {
    return BoxDecoration(
      gradient: isDark
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F3460),
              ],
            )
          : DesignTokens.primaryGradient,
    );
  }

  Widget _buildHeaderContent(BuildContext context, ThemeData theme) {
    return Stack(
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onBackPressed,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            tooltip: 'Zurück',
          ),
        ),
        
        // Reorder button (only show if there are buttons and not currently reordering)
        if (quickButtonCount > 0 && !isReordering)
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onReorderToggle,
              icon: const Icon(Icons.sort_rounded, color: Colors.white),
              tooltip: 'Reihenfolge ändern',
            ),
          ),
        
        // Finish reordering button
        if (isReordering)
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onReorderToggle,
              icon: const Icon(Icons.check_rounded, color: Colors.white),
              tooltip: 'Sortierung beenden',
            ),
          ),
        
        // Title and count
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 56.0),
            child: _buildTitleRow(context, theme),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            isReordering ? 'Reihenfolge ändern' : 'Quick Buttons verwalten',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (quickButtonCount > 0)
          _buildCountBadge(context, theme),
      ],
    );
  }

  Widget _buildCountBadge(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: Spacing.borderRadiusSm,
      ),
      child: Text(
        '$quickButtonCount',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}