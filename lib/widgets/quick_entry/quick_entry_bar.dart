import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/quick_button_config.dart';
import '../../services/timer_service.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import 'quick_button_widget.dart';
import '../../screens/quick_entry/quick_button_config_screen.dart';
import '../../utils/crash_protection.dart';

class QuickEntryBar extends StatefulWidget {
  final List<QuickButtonConfig> quickButtons;
  final Function(QuickButtonConfig) onQuickEntry;
  final VoidCallback? onAddButton;
  final VoidCallback? onEditMode;
  final bool isEditing;
  final Function(List<QuickButtonConfig>)? onReorder;

  const QuickEntryBar({
    super.key,
    required this.quickButtons,
    required this.onQuickEntry,
    this.onAddButton,
    this.onEditMode,
    this.isEditing = false,
    this.onReorder,
  });

  @override
  State<QuickEntryBar> createState() => _QuickEntryBarState();
}

class _QuickEntryBarState extends State<QuickEntryBar> with SafeStateMixin {
  final ScrollController _scrollController = ScrollController();
  List<QuickButtonConfig> _reorderedButtons = [];
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _reorderedButtons = List.from(widget.quickButtons);
  }

  @override
  void didUpdateWidget(QuickEntryBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quickButtons != widget.quickButtons) {
      _reorderedButtons = List.from(widget.quickButtons);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onReorder(int oldIndex, int newIndex) {
    safeSetState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _reorderedButtons.removeAt(oldIndex);
      _reorderedButtons.insert(newIndex, item);
      
      // Update positions
      for (int i = 0; i < _reorderedButtons.length; i++) {
        _reorderedButtons[i] = _reorderedButtons[i].copyWith(position: i);
      }
    });
    
    widget.onReorder?.call(_reorderedButtons);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.quickButtons.isEmpty && !widget.isEditing) {
      return _buildEmptyState(context, isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Optimized header with reduced spacing for compact layout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Schnelleingabe',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20, // Consistent sizing
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.quickButtons.isNotEmpty) ...[
                Spacing.horizontalSpaceXs,
                TextButton.icon(
                  onPressed: widget.onEditMode,
                  icon: Icon(
                    widget.isEditing ? Icons.check_rounded : Icons.edit_rounded,
                    size: Spacing.iconSm,
                  ),
                  label: Text(widget.isEditing ? 'Fertig' : 'Bearbeiten'),
                  style: TextButton.styleFrom(
                    foregroundColor: widget.isEditing 
                        ? DesignTokens.successGreen 
                        : DesignTokens.primaryIndigo,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        Spacing.verticalSpaceXs, // Reduced spacing for more compact layout
        
        // Quick buttons with improved alignment and height consistency
        Consumer<TimerService>(
          builder: (context, timerService, child) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 100, // Ensure consistent minimum height
                maxHeight: widget.isEditing ? 120 : 140, // Consistent height constraints
              ),
              child: Container(
                // Ensure symmetric padding for better visual balance
                padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
                child: widget.isEditing
                    ? _buildReorderableButtonList(context, isDark)
                    : _buildNormalButtonList(context, isDark, timerService),
              ),
            );
          },
        ),
        
        // Compact edit mode instructions with better overflow handling
        if (widget.isEditing) ...[
          const SizedBox(height: 4), // Minimal spacing
          Container(
            constraints: const BoxConstraints(
              maxHeight: 32, // Constrain height to prevent overflow
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DesignTokens.warningYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: DesignTokens.warningYellow.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Use minimum space needed
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: DesignTokens.warningYellow,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Ziehen • Tippen',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: DesignTokens.warningYellow,
                      fontSize: 10,
                      height: 1.0, // Tighter line height
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNormalButtonList(BuildContext context, bool isDark, TimerService timerService) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Ensure vertical centering
      children: [
        // Quick buttons in a scrollable container with improved centering
        Expanded(
          child: Container(
            height: 100, // Fixed height for consistent button alignment
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.quickButtons.length,
              itemBuilder: (context, index) {
                final button = widget.quickButtons[index];
                
                // Check if there's an active timer for this substance
                final activeTimer = timerService.getActiveTimer();
                final hasActiveTimer = activeTimer != null && 
                                     activeTimer.substanceId == button.substanceId;
                
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < widget.quickButtons.length - 1 ? Spacing.sm : 0,
                  ),
                  child: Center( // Center each button vertically within the container
                    child: _buildQuickButtonWithTimer(
                      button: button,
                      hasActiveTimer: hasActiveTimer,
                      timerProgress: hasActiveTimer ? activeTimer.timerProgress : 0.0,
                      onTap: () => widget.onQuickEntry(button),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Add button with improved alignment and consistent height
        Container(
          height: 100, // Match the height of the scrollable container
          child: Center( // Center the add button vertically
            child: AddQuickButtonWidget(
              key: ValueKey('add_button_normal_mode'),
              onTap: widget.onAddButton,
            ),
          ),
        ),
      ],
    );
  }

  // New method to build quick button with timer status indicator
  Widget _buildQuickButtonWithTimer({
    required QuickButtonConfig button,
    required bool hasActiveTimer,
    required double timerProgress,
    required VoidCallback onTap,
  }) {
    return Stack(
      children: [
        QuickButtonWidget(
          key: ValueKey('quickbutton_${button.id}_${button.position}'),
          config: button,
          isEditing: false,
          onTap: onTap,
          onLongPress: widget.onEditMode,
        ),
        
        // Timer progress indicator
        if (hasActiveTimer)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _getTimerColor(timerProgress),
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.timer,
                  size: 12,
                  color: _getTimerColor(timerProgress),
                ),
              ),
            ),
          ),
        
        // Timer progress ring
        if (hasActiveTimer)
          Positioned(
            top: 2,
            right: 2,
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: timerProgress,
                strokeWidth: 2,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getTimerColor(timerProgress),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Helper method to get timer color based on progress
  Color _getTimerColor(double progress) {
    if (progress < 0.3) {
      return DesignTokens.successGreen;
    } else if (progress < 0.7) {
      return DesignTokens.warningYellow;
    } else {
      return DesignTokens.errorRed;
    }
  }

  Widget _buildReorderableButtonList(BuildContext context, bool isDark) {
    // Handle empty state with neutral fallback display
    if (_reorderedButtons.isEmpty) {
      return Container(
        height: 100,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Text(
                  'Keine Buttons zum Sortieren',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 100,
                child: Center(
                  child: AddQuickButtonWidget(
                    key: ValueKey('add_button_reorder_empty'),
                    onTap: widget.onAddButton,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Reorderable buttons with improved unique keys and consistent height
        Expanded(
          child: Container(
            height: 100, // Fixed height for consistent alignment
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              onReorder: _onReorder,
              itemCount: _reorderedButtons.length,
              itemBuilder: (context, index) {
                final button = _reorderedButtons[index];
                // Improved unique key combining ID and position for better stability
                return Container(
                  key: ValueKey('reorder_${button.id}_pos_${button.position}_idx_$index'),
                  height: 100, // Ensure consistent height
                  child: Center( // Center each button vertically
                    child: QuickButtonWidget(
                      config: button,
                      isEditing: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QuickButtonConfigScreen(existingConfig: button),
                        ),
                      ),
                      onLongPress: () {},
                    ),
                  ),
                );
              },
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final double scale = 1.0 + animation.value * 0.1;
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: child,
                );
              },
            ),
          ),
        ),
        // Add button with consistent height and alignment
        Container(
          height: 100,
          child: Center(
            child: AddQuickButtonWidget(
              key: ValueKey('add_button_reorder_${_reorderedButtons.length}'), 
              onTap: widget.onAddButton,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 120, // Consistent minimum height
        maxHeight: 180, // Prevent overflow with reasonable maximum
      ),
      child: Container(
        // Symmetric padding for better visual balance
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isDark
              ? DesignTokens.glassGradientDark
              : DesignTokens.glassGradientLight,
          borderRadius: Spacing.borderRadiusLg,
          border: Border.all(
            color: isDark
                ? DesignTokens.glassBorderDark
                : DesignTokens.glassBorderLight,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use minimum space needed
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: [
            Icon(
              Icons.flash_on_rounded,
              size: Spacing.iconLg,
              color: DesignTokens.primaryIndigo,
            ),
            Spacing.verticalSpaceXs,
            Text(
              'Schnelleingabe einrichten',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: DesignTokens.primaryIndigo,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Spacing.verticalSpaceXs,
            Flexible(
              child: Text(
                'Erstellen Sie Quick Buttons für häufig verwendete Substanzen.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Spacing.verticalSpaceXs,
            // Constrained button to prevent overflow
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 200,
                minHeight: 32,
                maxHeight: 40,
              ),
              child: ElevatedButton.icon(
                onPressed: widget.onAddButton,
                icon: const Icon(Icons.add_rounded, size: 14),
                label: const Text(
                  'Ersten Button erstellen',
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryIndigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}