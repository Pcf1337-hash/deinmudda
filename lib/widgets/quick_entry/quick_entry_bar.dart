import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/quick_button_config.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import 'quick_button_widget.dart';
import '../../screens/quick_entry/quick_button_config_screen.dart';

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

class _QuickEntryBarState extends State<QuickEntryBar> {
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
    setState(() {
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
        
        Spacing.verticalSpaceMd,
        
        // Quick buttons scroll view
        SizedBox(
          height: 100,
          child: widget.isEditing
              ? _buildReorderableButtonList(context, isDark)
              : _buildNormalButtonList(context, isDark),
        ),
        
        // Edit mode instructions
        if (widget.isEditing) ...[
          Spacing.verticalSpaceMd,
          Container(
            padding: Spacing.paddingMd,
            decoration: BoxDecoration(
              color: DesignTokens.warningYellow.withOpacity(0.1),
              borderRadius: Spacing.borderRadiusMd,
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
                  size: Spacing.iconMd,
                ),
                Spacing.horizontalSpaceMd,
                Expanded(
                  child: Text(
                    'Ziehen Sie die Buttons, um die Reihenfolge zu ändern. Tippen Sie auf einen Button, um ihn zu bearbeiten.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: DesignTokens.warningYellow,
                    ),
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
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      itemCount: widget.quickButtons.length + 1, // +1 for add button
      itemBuilder: (context, index) {
        if (index == widget.quickButtons.length) {
          return AddQuickButtonWidget(
            onTap: widget.onAddButton,
          );
        }

        final button = widget.quickButtons[index];
        return QuickButtonWidget(
          key: ValueKey(button.id),
          config: button,
          isEditing: false,
          onTap: () => widget.onQuickEntry(button),
          onLongPress: widget.onEditMode,
        );
      },
    );
  }

  Widget _buildReorderableButtonList(BuildContext context, bool isDark) {
    return ReorderableListView.builder(
      scrollDirection: Axis.horizontal,
      onReorder: _onReorder,
      itemCount: _reorderedButtons.length + 1, // +1 for add button
      itemBuilder: (context, index) {
        if (index == _reorderedButtons.length) {
          return AddQuickButtonWidget(
            key: const ValueKey('add_button'),
            onTap: widget.onAddButton,
          );
        }

        final button = _reorderedButtons[index];
        return QuickButtonWidget(
          key: ValueKey(button.id),
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
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
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
      child: Column(
        children: [
          Icon(
            Icons.flash_on_rounded,
            size: Spacing.iconXl,
            color: DesignTokens.primaryIndigo,
          ),
          Spacing.verticalSpaceMd,
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
          ),
          Spacing.verticalSpaceMd,
          ElevatedButton.icon(
            onPressed: widget.onAddButton,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ersten Button erstellen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryIndigo,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}