import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../utils/data_export_helper.dart';
import '../widgets/glass_card.dart';
import '../widgets/modern_fab.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';

class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  final DataExportHelper _exportHelper = DataExportHelper();
  
  bool _isExporting = false;
  bool _isImporting = false;
  String? _exportPath;
  String? _errorMessage;
  List<Map<String, dynamic>> _availableBackups = [];
  bool _isLoadingBackups = false;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() {
      _isLoadingBackups = true;
      _errorMessage = null;
    });

    try {
      final backups = await _exportHelper.getAvailableBackups();
      setState(() {
        _availableBackups = backups;
        _isLoadingBackups = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden der Backups: $e';
        _isLoadingBackups = false;
      });
    }
  }

  Future<void> _exportAllData() async {
    setState(() {
      _isExporting = true;
      _errorMessage = null;
      _exportPath = null;
    });

    try {
      final path = await _exportHelper.exportAllData();
      setState(() {
        _exportPath = path;
        _isExporting = false;
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Daten erfolgreich exportiert nach: $path'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Teilen',
              textColor: Colors.white,
              onPressed: () => _shareExportedData(path),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Exportieren: $e';
        _isExporting = false;
      });
    }
  }

  Future<void> _exportEntriesAsCsv() async {
    setState(() {
      _isExporting = true;
      _errorMessage = null;
      _exportPath = null;
    });

    try {
      final path = await _exportHelper.exportEntriesAsCsv();
      setState(() {
        _exportPath = path;
        _isExporting = false;
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Einträge erfolgreich als CSV exportiert nach: $path'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Teilen',
              textColor: Colors.white,
              onPressed: () => _shareExportedData(path),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Exportieren: $e';
        _isExporting = false;
      });
    }
  }

  Future<void> _shareExportedData(String path) async {
    try {
      await _exportHelper.shareExportedData(path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Teilen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createDatabaseBackup() async {
    setState(() {
      _isExporting = true;
      _errorMessage = null;
    });

    try {
      final path = await _exportHelper.createDatabaseBackup();
      
      setState(() {
        _isExporting = false;
      });
      
      // Reload backups
      await _loadBackups();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup erfolgreich erstellt: $path'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Erstellen des Backups: $e';
        _isExporting = false;
      });
    }
  }

  Future<void> _restoreDatabaseFromBackup(String path) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup wiederherstellen'),
        content: const Text(
          'Sind Sie sicher, dass Sie dieses Backup wiederherstellen möchten? '
          'Alle aktuellen Daten werden überschrieben und dieser Vorgang kann nicht rückgängig gemacht werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: DesignTokens.errorRed,
            ),
            child: const Text('Wiederherstellen'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    try {
      await _exportHelper.restoreDatabaseFromBackup(path);
      
      setState(() {
        _isImporting = false;
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup erfolgreich wiederhergestellt. Die App wird neu gestartet.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to restart the app
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler bei der Wiederherstellung: $e';
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isDark),
          SliverPadding(
            padding: Spacing.paddingHorizontalMd,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_errorMessage != null) ...[
                  _buildErrorCard(context, isDark),
                  Spacing.verticalSpaceMd,
                ],
                _buildExportSection(context, isDark),
                Spacing.verticalSpaceLg,
                _buildBackupSection(context, isDark),
                Spacing.verticalSpaceLg,
                _buildImportSection(context, isDark),
                const SizedBox(height: 120), // Bottom padding
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildCreateBackupButton(context, isDark),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Daten-Export & Import',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(
                    duration: DesignTokens.animationSlow,
                    delay: const Duration(milliseconds: 200),
                  ).slideX(
                    begin: -0.3,
                    end: 0,
                    duration: DesignTokens.animationSlow,
                    curve: DesignTokens.curveEaseOut,
                  ),
                ],
              ),
            ),
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
            child: Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DesignTokens.errorRed,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
    ).slideY(
      begin: -0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Widget _buildExportSection(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.download_rounded,
                color: DesignTokens.primaryIndigo,
                size: Spacing.iconMd,
              ),
              Spacing.horizontalSpaceSm,
              Text(
                'Daten exportieren',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Spacing.verticalSpaceMd,
          Text(
            'Exportieren Sie Ihre Daten zur Sicherung oder zur Verwendung in anderen Anwendungen.',
            style: theme.textTheme.bodyMedium,
          ),
          Spacing.verticalSpaceMd,
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isExporting ? null : _exportAllData,
                  icon: _isExporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.download_rounded),
                  label: const Text('Alle Daten (JSON)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.primaryIndigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              Spacing.horizontalSpaceMd,
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isExporting ? null : _exportEntriesAsCsv,
                  icon: _isExporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.table_chart_rounded),
                  label: const Text('Einträge (CSV)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.accentCyan,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (_exportPath != null) ...[
            Spacing.verticalSpaceMd,
            Container(
              padding: Spacing.paddingMd,
              decoration: BoxDecoration(
                color: DesignTokens.successGreen.withOpacity(0.1),
                borderRadius: Spacing.borderRadiusMd,
                border: Border.all(
                  color: DesignTokens.successGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: DesignTokens.successGreen,
                        size: Spacing.iconMd,
                      ),
                      Spacing.horizontalSpaceSm,
                      Text(
                        'Export erfolgreich',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.successGreen,
                        ),
                      ),
                    ],
                  ),
                  Spacing.verticalSpaceXs,
                  Text(
                    'Datei: $_exportPath',
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacing.verticalSpaceSm,
                  ElevatedButton.icon(
                    onPressed: () => _shareExportedData(_exportPath!),
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Teilen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignTokens.successGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 300),
    ).slideY(
      begin: 0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Widget _buildBackupSection(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'de_DE');

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.backup_rounded,
                color: DesignTokens.accentEmerald,
                size: Spacing.iconMd,
              ),
              Spacing.horizontalSpaceSm,
              Text(
                'Datenbank-Backups',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Spacing.verticalSpaceMd,
          Text(
            'Erstellen und verwalten Sie Backups Ihrer Datenbank. Backups können jederzeit wiederhergestellt werden.',
            style: theme.textTheme.bodyMedium,
          ),
          Spacing.verticalSpaceMd,
          if (_isLoadingBackups)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(Spacing.md),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_availableBackups.isEmpty)
            Container(
              padding: Spacing.paddingMd,
              decoration: BoxDecoration(
                color: DesignTokens.infoBlue.withOpacity(0.1),
                borderRadius: Spacing.borderRadiusMd,
                border: Border.all(
                  color: DesignTokens.infoBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: DesignTokens.infoBlue,
                    size: Spacing.iconMd,
                  ),
                  Spacing.verticalSpaceSm,
                  Text(
                    'Keine Backups vorhanden',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Spacing.verticalSpaceXs,
                  Text(
                    'Erstellen Sie Ihr erstes Backup mit dem Button unten.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _availableBackups.length,
              itemBuilder: (context, index) {
                final backup = _availableBackups[index];
                final fileName = backup['name'] as String;
                final modified = backup['modified'] as DateTime;
                final size = backup['size'] as int;
                final sizeInMb = (size / (1024 * 1024)).toStringAsFixed(2);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.sm),
                  child: Container(
                    padding: Spacing.paddingMd,
                    decoration: BoxDecoration(
                      color: isDark
                          ? DesignTokens.neutral800.withOpacity(0.3)
                          : DesignTokens.neutral100.withOpacity(0.5),
                      borderRadius: Spacing.borderRadiusMd,
                      border: Border.all(
                        color: isDark
                            ? DesignTokens.neutral700
                            : DesignTokens.neutral300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(Spacing.sm),
                          decoration: BoxDecoration(
                            color: DesignTokens.accentEmerald.withOpacity(0.1),
                            borderRadius: Spacing.borderRadiusMd,
                          ),
                          child: Icon(
                            Icons.backup_rounded,
                            color: DesignTokens.accentEmerald,
                            size: Spacing.iconMd,
                          ),
                        ),
                        Spacing.horizontalSpaceMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${dateFormat.format(modified)} • $sizeInMb MB',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _isImporting
                              ? null
                              : () => _restoreDatabaseFromBackup(backup['path'] as String),
                          icon: _isImporting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.restore_rounded),
                          tooltip: 'Wiederherstellen',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 400),
    ).slideY(
      begin: 0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Widget _buildImportSection(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.upload_rounded,
                color: DesignTokens.warningYellow,
                size: Spacing.iconMd,
              ),
              Spacing.horizontalSpaceSm,
              Text(
                'Daten importieren',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Spacing.verticalSpaceMd,
          Text(
            'Importieren Sie Daten aus einer zuvor erstellten Export-Datei. Bestehende Daten werden nicht überschrieben.',
            style: theme.textTheme.bodyMedium,
          ),
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
            child: Column(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: DesignTokens.warningYellow,
                  size: Spacing.iconMd,
                ),
                Spacing.verticalSpaceSm,
                Text(
                  'Import-Funktion',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                Spacing.verticalSpaceXs,
                Text(
                  'Die Import-Funktion ist in dieser Version noch nicht verfügbar. Bitte verwenden Sie die Backup-Funktion, um Ihre Daten zu sichern und wiederherzustellen.',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 500),
    ).slideY(
      begin: 0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Widget _buildCreateBackupButton(BuildContext context, bool isDark) {
    return ModernFAB(
      onPressed: _isExporting ? null : _createDatabaseBackup,
      icon: _isExporting ? null : Icons.backup_rounded,
      label: _isExporting ? 'Backup wird erstellt...' : 'Backup erstellen',
      backgroundColor: DesignTokens.accentEmerald,
      isLoading: _isExporting,
    ).animate().fadeIn(
      duration: DesignTokens.animationSlow,
      delay: const Duration(milliseconds: 600),
    ).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      duration: DesignTokens.animationSlow,
      curve: DesignTokens.curveBack,
    );
  }
}