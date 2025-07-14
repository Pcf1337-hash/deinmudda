import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/entry.dart';
import '../services/entry_service.dart';
import '../services/timer_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/countdown_timer_widget.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';

class TimerDashboardScreen extends StatefulWidget {
  const TimerDashboardScreen({super.key});

  @override
  State<TimerDashboardScreen> createState() => _TimerDashboardScreenState();
}

class _TimerDashboardScreenState extends State<TimerDashboardScreen> {
  final EntryService _entryService = EntryService();
  final TimerService _timerService = TimerService();
  
  List<Entry> _activeEntries = [];
  List<Map<String, dynamic>> _customTimers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadActiveTimers();
  }

  Future<void> _loadActiveTimers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final entries = await _entryService.getAllEntries();
      final activeEntries = entries.where((entry) => 
        entry.hasTimer && entry.isTimerActive && !entry.timerCompleted
      ).toList();

      setState(() {
        _activeEntries = activeEntries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
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
          setState(() {
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

    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(context, isDark),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _buildTimersList(context, isDark),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomTimerDialog,
        backgroundColor: DesignTokens.accentCyan,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Neuer Timer',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      height: 90, // Consistent with dosage calculator
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
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.timer_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Timer Dashboard',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aktive Timer & Countdowns',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
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

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildTimersList(BuildContext context, bool isDark) {
    if (_activeEntries.isEmpty && _customTimers.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadActiveTimers,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_activeEntries.isNotEmpty) ...[
            _buildSectionHeader('Substanz-Timer', Icons.medication_rounded),
            const SizedBox(height: 16),
            ..._activeEntries.map((entry) => _buildEntryTimer(entry, isDark)),
          ],
          
          if (_customTimers.isNotEmpty) ...[
            if (_activeEntries.isNotEmpty) const SizedBox(height: 24),
            _buildSectionHeader('Benutzerdefinierte Timer', Icons.timer_rounded),
            const SizedBox(height: 16),
            ..._customTimers.map((timer) => _buildCustomTimer(timer, isDark)),
          ],
          
          const SizedBox(height: 100), // Bottom padding for FAB
        ],
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
                setState(() {
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white20 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 64,
                    color: DesignTokens.accentCyan,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Keine aktiven Timer',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: DesignTokens.accentCyan,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Erstellen Sie einen benutzerdefinierten Timer oder starten Sie einen Timer bei einem Eintrag',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
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
                ],
              ),
            ),
          ],
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

class _CustomTimerDialogState extends State<_CustomTimerDialog> {
  final _titleController = TextEditingController();
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      title: Text(
        'Neuer Timer',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
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
          Text(
            'Dauer: ${_duration.inMinutes} Minuten',
            style: theme.textTheme.bodyMedium,
          ),
          Slider(
            value: _duration.inMinutes.toDouble(),
            min: 1,
            max: 240,
            divisions: 239,
            activeColor: _selectedColor,
            onChanged: (value) {
              setState(() {
                _duration = Duration(minutes: value.toInt());
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Farbe:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _colors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
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