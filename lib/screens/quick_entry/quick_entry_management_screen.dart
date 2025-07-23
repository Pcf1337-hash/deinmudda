import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/quick_button_config.dart';
import '../../services/quick_button_service.dart';
import '../../interfaces/service_interfaces.dart';
import '../../utils/service_locator.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/modern_fab.dart';
import '../../widgets/quick_entry/quick_button_list.dart';
import '../../widgets/quick_entry/quick_entry_management_header.dart';
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
  late final IQuickButtonService _quickButtonService;

  List<QuickButtonConfig> _quickButtons = [];
  bool _isLoading = true;
  bool _isReordering = false;
  bool _isDisposed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _quickButtonService = ServiceLocator.get<IQuickButtonService>();
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
      // Immediately show loading state while refreshing
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      await _loadQuickButtons();
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
      // Immediately remove from local state for instant UI update
      setState(() {
        _quickButtons.removeWhere((button) => button.id == config.id);
      });
      
      // Then delete from the service
      await _quickButtonService.deleteQuickButton(config.id);
      
      // Reload to ensure consistency with backend
      await _loadQuickButtons();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quick Button erfolgreich gelöscht'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // If there was an error, reload the buttons to restore the correct state
      await _loadQuickButtons();
      
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
    return Scaffold(
      body: Column(
        children: [
          QuickEntryManagementHeader(
            quickButtonCount: _quickButtons.length,
            isReordering: _isReordering,
            onBackPressed: () => Navigator.of(context).pop(),
            onReorderToggle: _toggleReordering,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: Spacing.paddingHorizontalMd,
              child: Column(
                children: [
                  if (_errorMessage != null) ...[
                    Spacing.verticalSpaceMd,
                    _buildErrorCard(),
                    Spacing.verticalSpaceMd,
                  ],
                  if (_isLoading)
                    _buildLoadingState()
                  else
                    _buildQuickButtonsContent(),
                  const SizedBox(height: 120), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

  void _toggleReordering() {
    if (mounted) {
      setState(() {
        _isReordering = !_isReordering;
      });
    }
  }

  Widget _buildErrorCard() {
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

  Widget _buildQuickButtonsContent() {
    return QuickButtonList(
      quickButtons: _quickButtons,
      isReordering: _isReordering,
      onEditButton: (config) => _navigateToConfigScreen(config),
      onDeleteButton: (config) => _deleteQuickButton(config),
      onReorder: (reorderedButtons) => _reorderQuickButtons(reorderedButtons),
    );
  }

  Widget _buildAddButton() {
    return ModernFAB(
      onPressed: () => _navigateToConfigScreen(),
      icon: Icons.add_rounded,
      label: 'Quick Button',
      backgroundColor: DesignTokens.primaryIndigo,
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


}