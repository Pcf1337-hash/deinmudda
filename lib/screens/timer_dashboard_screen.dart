import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/entry.dart';
import '../services/entry_service.dart';
import '../services/timer_service.dart';
import '../services/psychedelic_theme_service.dart';
import '../interfaces/service_interfaces.dart';
import '../utils/service_locator.dart';
import '../widgets/glass_card.dart';
import '../widgets/countdown_timer_widget.dart';
import '../widgets/trippy_fab.dart';
import '../widgets/header_bar.dart';
import '../widgets/consistent_fab.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';
import '../utils/crash_protection.dart';

class TimerDashboardScreen extends StatefulWidget {
  const TimerDashboardScreen({super.key});

  @override
  State<TimerDashboardScreen> createState() => _TimerDashboardScreenState();
}

class _TimerDashboardScreenState extends State<TimerDashboardScreen> with SafeStateMixin {
  late final IEntryService _entryService;
  late final ITimerService _timerService;
  
  List<Entry> _activeEntries = [];
  List<Map<String, dynamic>> _customTimers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    // Get services from ServiceLocator
    _entryService = ServiceLocator.get<IEntryService>();
    _timerService = ServiceLocator.get<ITimerService>();
    
    _loadActiveTimers();
  }

  Future<void> _loadActiveTimers() async {
    safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final entries = await _entryService.getAllEntries();
      final activeEntries = entries.where((entry) => 
        entry.hasTimer && entry.isTimerActive && !entry.timerCompleted
      ).toList();

      safeSetState(() {
        _activeEntries = activeEntries;
        _isLoading = false;
      });
    } catch (e) {
      safeSetState(() {
        _errorMessage = 'Fehler beim Laden der Timer: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _stopTimer(Entry entry) async {
    try {
      await _timerService.stopTimer(entry);
      _loadActiveTimers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Stoppen des Timers: $e')),
      );
    }
  }

  void _showAddCustomTimerDialog() {
    showDialog(
      context: context,
      builder: (context) => _CustomTimerDialog(
        onTimerCreated: (timer) {
          safeSetState(() {
            _customTimers.add(timer);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<PsychedelicThemeService>(
      builder: (context, psychedelicService, child) {
        final isPsychedelicMode = psychedelicService.isPsychedelicMode;
        
        return Scaffold(
          backgroundColor: isPsychedelicMode 
            ? DesignTokens.psychedelicBackground 
            : null,
          body: Container(
            decoration: isPsychedelicMode 
              ? const BoxDecoration(
                  gradient: DesignTokens.psychedelicBackground1,
                ) 
              : null,
            child: Column(
              children: [
                HeaderBar(
                  title: 'Timer Dashboard',
                  subtitle: 'Aktive Timer & Countdowns',
                  showLightningIcon: true,
                ),
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState(psychedelicService)
                      : _buildTimersList(context, isDark, psychedelicService),
                ),
              ],
            ),
          ),
          floatingActionButton: ConsistentFAB(
            speedDialChildren: [
              FABHelper.createSpeedDialChild(
                icon: Icons.add_rounded,
                label: 'Neuer Timer',
                backgroundColor: DesignTokens.accentCyan,
                onTap: _showAddCustomTimerDialog,
              ),
            ],
            mainIcon: Icons.timer_rounded,
            backgroundColor: DesignTokens.accentCyan,
            onMainAction: _showAddCustomTimerDialog,
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(PsychedelicThemeService psychedelicService) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildTimersList(BuildContext context, bool isDark, PsychedelicThemeService psychedelicService) {
    if (_activeEntries.isEmpty && _customTimers.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadActiveTimers,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_activeEntries.isNotEmpty) ...[
                _buildSectionHeader('Substanz-Timer', Icons.medication_rounded),
                const SizedBox(height: 16),
                ..._activeEntries.map((entry) => Container(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth - 32, // Account for padding
                  ),
                  child: _buildEntryTimer(entry, isDark),
                )),
              ],
              
              if (_customTimers.isNotEmpty) ...[
                if (_activeEntries.isNotEmpty) const SizedBox(height: 24),
                _buildSectionHeader('Benutzerdefinierte Timer', Icons.timer_rounded),
                const SizedBox(height: 16),
                ..._customTimers.map((timer) => Container(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth - 32, // Account for padding
                  ),
                  child: _buildCustomTimer(timer, isDark),
                )),
              ],
              
              const SizedBox(height: 100), // Bottom padding for FAB
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: DesignTokens.accentCyan),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DesignTokens.accentCyan,
          ),
        ),
      ],
    );
  }

  Widget _buildEntryTimer(Entry entry, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          CountdownTimer.createEffectTimer(
            substanceName: entry.substanceName,
            startTime: entry.timerStartTime!,
            effectDuration: entry.timerEndTime!.difference(entry.timerStartTime!),
            onComplete: () => _loadActiveTimers(),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _stopTimer(entry),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.stop_rounded,
                  color: Colors.red,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTimer(Map<String, dynamic> timer, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          CountdownTimer.createCustomTimer(
            title: timer['title'] as String,
            endTime: timer['endTime'] as DateTime,
            accentColor: Color(timer['color'] as int),
            onComplete: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Timer "${timer['title']}" ist abgelaufen!'),
                  backgroundColor: Color(timer['color'] as int),
                ),
              );
            },
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                safeSetState(() {
                  _customTimers.remove(timer);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.red,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: const BoxConstraints(
                  minHeight: 200,
                  maxHeight: 400,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 64,
                      color: DesignTokens.accentCyan,
                    ),
                    const SizedBox(height: 16),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Keine aktiven Timer',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: DesignTokens.accentCyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        'Erstellen Sie einen benutzerdefinierten Timer oder starten Sie einen Timer bei einem Eintrag',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _showAddCustomTimerDialog,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Timer erstellen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignTokens.accentCyan,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.home_rounded),
                            label: const Text('Zurück'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: DesignTokens.accentCyan),
                              foregroundColor: DesignTokens.accentCyan,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomTimerDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onTimerCreated;

  const _CustomTimerDialog({required this.onTimerCreated});

  @override
  State<_CustomTimerDialog> createState() => _CustomTimerDialogState();
}

class _CustomTimerDialogState extends State<_CustomTimerDialog> with SafeStateMixin {
  final _titleController = TextEditingController();
  final _minutesController = TextEditingController(text: '30');
  Duration _duration = const Duration(minutes: 30);
  Color _selectedColor = DesignTokens.accentCyan;

  final List<Color> _colors = [
    DesignTokens.accentCyan,
    DesignTokens.accentPurple,
    DesignTokens.accentPink,
    Colors.green,
    Colors.orange,
    Colors.red,
  ];

  @override
  void initState() {
    super.initState();
    _minutesController.addListener(_updateDurationFromText);
  }

  @override
  void dispose() {
    _minutesController.removeListener(_updateDurationFromText);
    _minutesController.dispose();
    super.dispose();
  }

  void _updateDurationFromText() {
    final text = _minutesController.text;
    if (text.isNotEmpty) {
      final minutes = int.tryParse(text) ?? 30;
      if (minutes != _duration.inMinutes) {
        safeSetState(() {
          _duration = Duration(minutes: minutes.clamp(1, 1440)); // Max 24 hours
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return 'Entspricht: $hours Stunde${hours > 1 ? 'n' : ''}, $minutes Minute${minutes > 1 ? 'n' : ''}';
    } else {
      return 'Entspricht: $minutes Minute${minutes > 1 ? 'n' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'Neuer Timer',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Timer Name',
                hintText: 'z.B. Pause, Meditation, etc.',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minuten',
                hintText: 'z.B. 64',
                suffixText: 'min',
              ),
              onChanged: (value) {
                _updateDurationFromText();
              },
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                _formatDuration(_duration),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _selectedColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Oder wähle eine Voreinstellung:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [15, 30, 45, 60, 90, 120].map((minutes) {
                  return GestureDetector(
                    onTap: () {
                      safeSetState(() {
                        _duration = Duration(minutes: minutes);
                        _minutesController.text = minutes.toString();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _duration.inMinutes == minutes ? _selectedColor.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _duration.inMinutes == minutes ? _selectedColor : Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${minutes}min',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _duration.inMinutes == minutes ? _selectedColor : null,
                          fontWeight: _duration.inMinutes == minutes ? FontWeight.w600 : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Farbe:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8,
                children: _colors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      safeSetState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        border: _selectedColor == color
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty && _duration.inMinutes > 0) {
              widget.onTimerCreated({
                'title': _titleController.text,
                'endTime': DateTime.now().add(_duration),
                'color': _selectedColor.value,
              });
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Erstellen'),
        ),
      ],
    );
  }
}