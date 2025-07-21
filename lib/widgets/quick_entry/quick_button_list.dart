import 'package:flutter/material.dart';
import '../../models/quick_button_config.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/quick_entry/quick_button_widget.dart';
import '../../theme/spacing.dart';

/// Separated widget for managing quick button list display and interactions
/// This helps break down the complexity of QuickEntryManagementScreen
class QuickButtonList extends StatelessWidget {
  final List<QuickButtonConfig> quickButtons;
  final bool isReordering;
  final Function(QuickButtonConfig) onEditButton;
  final Function(QuickButtonConfig) onDeleteButton;
  final Function(List<QuickButtonConfig>) onReorder;

  const QuickButtonList({
    super.key,
    required this.quickButtons,
    required this.isReordering,
    required this.onEditButton,
    required this.onDeleteButton,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    // Safety check to prevent gray area issues
    try {
      if (quickButtons.isEmpty) {
        return _buildEmptyState(context);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstructions(context),
          const SizedBox(height: Spacing.lg),
          isReordering
              ? _buildReorderableGrid(context)
              : _buildNormalGrid(context),
        ],
      );
    } catch (e, stackTrace) {
      // If rendering fails, show a safe fallback
      debugPrint('QuickButtonList render error: $e');
      debugPrint('Stack trace: $stackTrace');
      
      return GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                'Fehler beim Laden der Quick Buttons',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Bitte versuchen Sie die Seite neu zu laden.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Icon(
            Icons.flash_on_rounded,
            size: Spacing.iconXl,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'Noch keine Quick Buttons',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'Erstellen Sie Quick Buttons für häufig verwendete Substanzen und Dosierungen.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.blue,
            size: Spacing.iconMd,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              isReordering
                  ? 'Ziehen Sie die Buttons, um die Reihenfolge zu ändern.'
                  : 'Tippen Sie auf einen Button zum Bearbeiten oder halten Sie ihn gedrückt zum Löschen.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        try {
          // Responsive grid column calculation
          final screenWidth = constraints.maxWidth;
          final crossAxisCount = _calculateCrossAxisCount(screenWidth);
          final childAspectRatio = _calculateChildAspectRatio(screenWidth);
          
          // Safety check for invalid dimensions
          if (screenWidth <= 0 || crossAxisCount <= 0) {
            return const SizedBox.shrink();
          }
          
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: Spacing.md,
              mainAxisSpacing: Spacing.md,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: quickButtons.length,
            itemBuilder: (context, index) {
              if (index >= quickButtons.length) {
                return const SizedBox.shrink(); // Safety check for index bounds
              }
              
              final button = quickButtons[index];
              return GestureDetector(
                onTap: () => onEditButton(button),
                onLongPress: () => onDeleteButton(button),
                child: QuickButtonWidget(
                  key: ValueKey(button.id),
                  config: button,
                  onTap: () => onEditButton(button),
                  onLongPress: () => onDeleteButton(button),
                ),
              );
            },
          );
        } catch (e, stackTrace) {
          debugPrint('Grid build error: $e');
          debugPrint('Stack trace: $stackTrace');
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildReorderableGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final crossAxisCount = _calculateCrossAxisCount(screenWidth);
        final childAspectRatio = _calculateChildAspectRatio(screenWidth);
        
        return ReorderableGridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: Spacing.md,
            mainAxisSpacing: Spacing.md,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: quickButtons.length,
          itemBuilder: (context, index) {
            final button = quickButtons[index];
            return QuickButtonWidget(
              key: ValueKey(button.id),
              config: button,
              isDragging: false,
              isEditing: true,
            );
          },
          onReorder: (oldIndex, newIndex) {
            final reorderedButtons = List<QuickButtonConfig>.from(quickButtons);
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = reorderedButtons.removeAt(oldIndex);
            reorderedButtons.insert(newIndex, item);
            
            // Update positions
            for (int i = 0; i < reorderedButtons.length; i++) {
              reorderedButtons[i] = reorderedButtons[i].copyWith(position: i);
            }
            
            onReorder(reorderedButtons);
          },
        );
      },
    );
  }

  /// Calculate optimal cross axis count based on screen width
  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) {
      return 2; // Small screens: 2 columns
    } else if (screenWidth < 900) {
      return 3; // Medium screens: 3 columns
    } else {
      return 4; // Large screens: 4 columns
    }
  }

  /// Calculate optimal child aspect ratio based on screen width
  double _calculateChildAspectRatio(double screenWidth) {
    if (screenWidth < 600) {
      return 0.75; // Slightly taller on small screens
    } else {
      return 0.8; // Standard ratio for larger screens
    }
  }
}

/// Custom reorderable grid view implementation
class ReorderableGridView extends StatefulWidget {
  final SliverGridDelegate gridDelegate;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final Function(int oldIndex, int newIndex) onReorder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ReorderableGridView.builder({
    super.key,
    required this.gridDelegate,
    required this.itemBuilder,
    required this.itemCount,
    required this.onReorder,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<ReorderableGridView> createState() => _ReorderableGridViewState();
}

class _ReorderableGridViewState extends State<ReorderableGridView> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return Container(
          key: ValueKey('grid_item_$index'),
          child: widget.itemBuilder(context, index),
        );
      },
      onReorder: widget.onReorder,
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
      buildDefaultDragHandles: false,
    );
  }
}