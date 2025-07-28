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
        // Improved header with better spacing
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
        
        // Quick buttons with timer status indicators
        Consumer<TimerService>(
          builder: (context, timerService, child) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 100, // Ensure minimum height matches button height
                maxHeight: widget.isEditing ? 120 : 120, // Slightly increased for timer indicators with better overflow control
              ),
              child: widget.isEditing
                  ? _buildReorderableButtonList(context, isDark)
                  : _buildNormalButtonList(context, isDark, timerService),
            );
          },
        ),
        
        // Edit mode instructions - compact version with better overflow handling
        if (widget.isEditing) ...[
          const SizedBox(height: 6), // Further reduced spacing
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Reduced padding
            decoration: BoxDecoration(
              color: DesignTokens.warningYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6), // Smaller radius
              border: Border.all(
                color: DesignTokens.warningYellow.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: DesignTokens.warningYellow,
                  size: 14, // Smaller icon
                ),
                const SizedBox(width: 6), // Further reduced spacing
                Expanded(
                  child: Text(
                    'Ziehen • Tippen', // Much shorter text to save space
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: DesignTokens.warningYellow,
                      fontSize: 11, // Smaller font
                      height: 1.2, // Reduce line height
                    ),
                    maxLines: 1, // Single line to save space
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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
      children: [
        // Quick buttons in a scrollable container with proper centering
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 100, // Match button height to prevent overflow
              maxWidth: MediaQuery.of(context).size.width - 120, // Leave space for add button
            ),
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: widget.quickButtons.length,
              itemBuilder: (context, index) {
                final button = widget.quickButtons[index];
                
                // Check if there's an active timer for this substance
                final activeTimer = timerService.getActiveTimer();
                final hasActiveTimer = activeTimer != null && 
                                     activeTimer.substanceId == button.substanceId;
                
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < widget.quickButtons.length - 1 ? Spacing.sm : Spacing.sm,
                  ),
                  child: _buildQuickButtonWithTimer(
                    button: button,
                    hasActiveTimer: hasActiveTimer,
                    timerProgress: hasActiveTimer ? activeTimer.timerProgress : 0.0,
                    onTap: () => widget.onQuickEntry(button),
                  ),
                );
              },
            ),
          ),
        ),
        // Add button with consistent spacing and alignment
        AddQuickButtonWidget(
          key: ValueKey('add_button_normal_mode'),
          onTap: widget.onAddButton,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
      children: [
        // Reorderable buttons in a scrollable container with proper centering
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 100, // Match button height to prevent overflow
              maxWidth: MediaQuery.of(context).size.width - 120, // Leave space for add button
            ),
            child: _reorderedButtons.isEmpty 
                ? _buildEmptyReorderableState(context)
                : ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    onReorder: _onReorder,
                    itemCount: _reorderedButtons.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final button = _reorderedButtons[index];
                      return Padding(
                        key: ValueKey('reorder_padding_${button.id}_${button.position}'),
                        padding: EdgeInsets.only(
                          right: index < _reorderedButtons.length - 1 ? Spacing.sm : Spacing.sm,
                        ),
                        child: QuickButtonWidget(
                          key: ValueKey('reorder_${button.id}_${button.position}'), // Stable key
                          config: button,
                          isEditing: true,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QuickButtonConfigScreen(existingConfig: button),
                            ),
                          ),
                          onLongPress: () {},
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
        // Add button with consistent spacing and alignment
        AddQuickButtonWidget(
          key: ValueKey('add_button_reorder_${_reorderedButtons.length}'), // Stable key based on list length
          onTap: widget.onAddButton,
        ),
      ],
    );
  }

  // Build empty state for reorderable list to prevent rendering issues
  Widget _buildEmptyReorderableState(BuildContext context) {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: Spacing.borderRadiusLg,
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
          style: BorderStyle.dashed,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.drag_indicator_rounded,
          color: Colors.grey.withOpacity(0.5),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 180, // Reduced height to prevent overflow while maintaining content
        minHeight: 120, // Ensure minimum reasonable height
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm), // Reduced padding
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: [
            Icon(
              Icons.flash_on_rounded,
              size: Spacing.iconMd, // Reduced from iconLg to fit better in constrained height
              color: DesignTokens.primaryIndigo,
            ),
            const SizedBox(height: Spacing.xs), // Reduced spacing
            Text(
              'Schnelleingabe einrichten',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: DesignTokens.primaryIndigo,
              ),
              textAlign: TextAlign.center,
              maxLines: 1, // Ensure single line
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Spacing.xs), // Reduced spacing
            Flexible(
              child: Text(
                'Erstellen Sie Quick Buttons für häufig verwendete Substanzen und Dosierungen.',
                style: theme.textTheme.bodySmall?.copyWith( // Changed to bodySmall for better fit
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Reduced from 3 to 2 lines to prevent overflow
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: Spacing.xs), // Reduced spacing
            // Use constrained container for button to prevent overflow
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 200, // Reduced width to fit better
                maxHeight: 32, // Explicit maximum height
              ),
              child: ElevatedButton.icon(
                onPressed: widget.onAddButton,
                icon: const Icon(Icons.add_rounded, size: 14), // Smaller icon
                label: const Text(
                  'Ersten Button erstellen',
                  style: TextStyle(fontSize: 11), // Smaller font
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryIndigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  minimumSize: const Size(120, 28), // Reduced minimum size
                  maximumSize: const Size(200, 32), // Reduced maximum size
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}