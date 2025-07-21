import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/quick_button_config.dart';
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
      mainAxisSize: MainAxisSize.min, // Use minimum size needed
      children: [
        // Header with edit button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Schnelleingabe',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.quickButtons.isNotEmpty)
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
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 8), // Further reduced spacing
        
        // Quick buttons scroll view - adjust height based on edit mode and make it flexible
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 80,
              maxHeight: widget.isEditing ? 110 : 130, // Slightly increased to prevent overflow
            ),
            child: widget.isEditing
                ? _buildReorderableButtonList(context, isDark)
                : _buildNormalButtonList(context, isDark),
          ),
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

  Widget _buildNormalButtonList(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Quick buttons in a scrollable container
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.quickButtons.length,
            itemBuilder: (context, index) {
              final button = widget.quickButtons[index];
              return QuickButtonWidget(
                key: ValueKey('normal_${button.id}'), // Make key more specific
                config: button,
                isEditing: false,
                onTap: () => widget.onQuickEntry(button),
                onLongPress: widget.onEditMode,
              );
            },
          ),
        ),
        // Add button always visible on the right
        AddQuickButtonWidget(
          key: const ValueKey('add_button_normal'), // Add unique key
          onTap: widget.onAddButton,
        ),
      ],
    );
  }

  Widget _buildReorderableButtonList(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Reorderable buttons in a scrollable container
        Expanded(
          child: ReorderableListView.builder(
            scrollDirection: Axis.horizontal,
            onReorder: _onReorder,
            itemCount: _reorderedButtons.length,
            itemBuilder: (context, index) {
              final button = _reorderedButtons[index];
              return QuickButtonWidget(
                key: ValueKey('reorder_${button.id}'), // Make key more specific
                config: button,
                isEditing: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QuickButtonConfigScreen(existingConfig: button),
                  ),
                ),
                onLongPress: () {},
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
        // Add button always visible on the right
        AddQuickButtonWidget(
          key: const ValueKey('add_button_reorder'), // More specific key
          onTap: widget.onAddButton,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 200, // Ensure empty state doesn't exceed reasonable height
      ),
      child: Container(
        padding: Spacing.paddingLg,
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
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flash_on_rounded,
                size: Spacing.iconLg, // Reduced from iconXl to fit better
                color: DesignTokens.primaryIndigo,
              ),
              Spacing.verticalSpaceSm, // Reduced from verticalSpaceMd
              Text(
                'Schnelleingabe einrichten',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.primaryIndigo,
                ),
                textAlign: TextAlign.center,
              ),
              Spacing.verticalSpaceXs,
              Text(
                'Erstellen Sie Quick Buttons für häufig verwendete Substanzen und Dosierungen.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 3, // Limit text lines to prevent overflow
                overflow: TextOverflow.ellipsis,
              ),
              Spacing.verticalSpaceSm, // Reduced from verticalSpaceMd
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 200, // Limit button width to prevent cut-off
                ),
                child: ElevatedButton.icon(
                  onPressed: widget.onAddButton,
                  icon: const Icon(Icons.add_rounded, size: 18), // Smaller icon
                  label: const Text(
                    'Ersten Button erstellen',
                    style: TextStyle(fontSize: 13), // Smaller text
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.primaryIndigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Smaller padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Smaller radius
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}