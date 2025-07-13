import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/quick_button_config.dart';
import '../../services/quick_button_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/modern_fab.dart';
import '../../widgets/quick_entry/quick_button_widget.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import 'quick_button_config_screen.dart';

class QuickEntryManagementScreen extends StatefulWidget {
  const QuickEntryManagementScreen({super.key});

  @override
  State<QuickEntryManagementScreen> createState() => _QuickEntryManagementScreenState();
}

class _QuickEntryManagementScreenState extends State<QuickEntryManagementScreen> {
  final _scrollController = ScrollController();
  final QuickButtonService _quickButtonService = QuickButtonService();

  List<QuickButtonConfig> _quickButtons = [];
  bool _isLoading = true;
  bool _isReordering = false;
  bool _isDisposed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuickButtons();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadQuickButtons() async {
    if (_isDisposed) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final buttons = await _quickButtonService.getAllQuickButtons();
      
      if (_isDisposed) return;
      
      setState(() {
        _quickButtons = buttons;
        _isLoading = false;
      });
    } catch (e) {
      if (_isDisposed) return;
      
      setState(() {
        _errorMessage = 'Fehler beim Laden der Quick Buttons: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToConfigScreen([QuickButtonConfig? config]) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuickButtonConfigScreen(existingConfig: config),
      ),
    );

    if (result == true) {
      _loadQuickButtons();
    }
  }

  Future<void> _deleteQuickButton(QuickButtonConfig config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Button löschen'),
        content: Text('Möchten Sie "${config.substanceName}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: DesignTokens.errorRed),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _quickButtonService.deleteQuickButton(config.id);
      _loadQuickButtons();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quick Button erfolgreich gelöscht'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Löschen: $e'),
            backgroundColor: DesignTokens.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _reorderQuickButtons(List<QuickButtonConfig> reorderedButtons) async {
    try {
      await _quickButtonService.reorderQuickButtons(reorderedButtons);
      
      if (_isDisposed) return;
      
      setState(() {
        _quickButtons = reorderedButtons;
        _isReordering = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reihenfolge erfolgreich aktualisiert'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (_isDisposed) return;
      
      setState(() {
        _isReordering = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Sortieren: $e'),
            backgroundColor: DesignTokens.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(context, isDark),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: Spacing.paddingHorizontalMd,
              child: Column(
                children: [
                  if (_errorMessage != null) ...[
                    Spacing.verticalSpaceMd,
                    _buildErrorCard(context, isDark),
                    Spacing.verticalSpaceMd,
                  ],
                  if (_isLoading)
                    _buildLoadingState()
                  else
                    _buildQuickButtonsContent(context, isDark),
                  const SizedBox(height: 120), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAddButton(context, isDark),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      height: 120,
      decoration: BoxDecoration(
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
      ),
      child: SafeArea(
        child: Padding(
          padding: Spacing.paddingMd,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
              ),
              if (_quickButtons.isNotEmpty && !_isReordering)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isReordering = true;
                      });
                    },
                    icon: const Icon(Icons.sort_rounded, color: Colors.white),
                    tooltip: 'Reihenfolge ändern',
                  ),
                ),
              if (_isReordering)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isReordering = false;
                      });
                    },
                    icon: const Icon(Icons.check_rounded, color: Colors.white),
                    tooltip: 'Sortierung beenden',
                  ),
                ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 56.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isReordering ? 'Reihenfolge ändern' : 'Quick Buttons verwalten',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (_quickButtons.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.sm,
                            vertical: Spacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: Spacing.borderRadiusSm,
                          ),
                          child: Text(
                            '${_quickButtons.length}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, bool isDark) {
    return GlassCard(
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: DesignTokens.errorRed,
            size: Spacing.iconLg,
          ),
          Spacing.horizontalSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fehler beim Laden',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: DesignTokens.errorRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacing.verticalSpaceXs,
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadQuickButtons,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: GlassCard(
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: Spacing.borderRadiusMd,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: const Duration(milliseconds: 1500)),
        );
      }),
    );
  }

  Widget _buildQuickButtonsContent(BuildContext context, bool isDark) {
    if (_quickButtons.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacing.verticalSpaceLg,
        
        // Instructions
        GlassCard(
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: DesignTokens.infoBlue,
                size: Spacing.iconMd,
              ),
              Spacing.horizontalSpaceMd,
              Expanded(
                child: Text(
                  _isReordering
                      ? 'Ziehen Sie die Buttons, um die Reihenfolge zu ändern.'
                      : 'Tippen Sie auf einen Button zum Bearbeiten oder halten Sie ihn gedrückt zum Löschen.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DesignTokens.infoBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        Spacing.verticalSpaceLg,
        
        // Quick buttons grid
        _isReordering
            ? _buildReorderableGrid(context, isDark)
            : _buildNormalGrid(context, isDark),
      ],
    );
  }

  Widget _buildNormalGrid(BuildContext context, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: Spacing.md,
        mainAxisSpacing: Spacing.md,
        childAspectRatio: 0.8,
      ),
      itemCount: _quickButtons.length,
      itemBuilder: (context, index) {
        final button = _quickButtons[index];
        return GestureDetector(
          onTap: () => _navigateToConfigScreen(button),
          onLongPress: () => _deleteQuickButton(button),
          child: QuickButtonWidget(
            key: ValueKey(button.id),
            config: button,
            onTap: () => _navigateToConfigScreen(button),
            onLongPress: () => _deleteQuickButton(button),
          ),
        );
      },
    );
  }

  Widget _buildReorderableGrid(BuildContext context, bool isDark) {
    return ReorderableGridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: Spacing.md,
        mainAxisSpacing: Spacing.md,
        childAspectRatio: 0.8,
      ),
      itemCount: _quickButtons.length,
      itemBuilder: (context, index) {
        final button = _quickButtons[index];
        return QuickButtonWidget(
          key: ValueKey(button.id),
          config: button,
          isDragging: false,
          isEditing: true,
        );
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = _quickButtons.removeAt(oldIndex);
          _quickButtons.insert(newIndex, item);
          
          // Update positions
          for (int i = 0; i < _quickButtons.length; i++) {
            _quickButtons[i] = _quickButtons[i].copyWith(position: i);
          }
        });
        
        _reorderQuickButtons(_quickButtons);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return GlassCard(
      child: Column(
        children: [
          Icon(
            Icons.flash_on_rounded,
            size: Spacing.iconXl,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
          ),
          Spacing.verticalSpaceMd,
          Text(
            'Noch keine Quick Buttons',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Spacing.verticalSpaceXs,
          Text(
            'Erstellen Sie Quick Buttons für häufig verwendete Substanzen und Dosierungen.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          Spacing.verticalSpaceMd,
          ElevatedButton.icon(
            onPressed: () => _navigateToConfigScreen(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ersten Quick Button erstellen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryIndigo,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, bool isDark) {
    return ModernFAB(
      onPressed: () => _navigateToConfigScreen(),
      icon: Icons.add_rounded,
      label: 'Quick Button',
      backgroundColor: DesignTokens.primaryIndigo,
    );
  }
}

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