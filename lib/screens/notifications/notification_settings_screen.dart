import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/notification_service.dart';
import '../../utils/service_locator.dart'; // refactored by ArchitekturAgent
import '../../widgets/glass_card.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late final NotificationService _notificationService = ServiceLocator.get<NotificationService>(); // refactored by ArchitekturAgent
  
  bool _isLoading = true;
  bool _notificationsEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7]; // All days by default
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Initialize notification service
      await _notificationService.init();
      
      // Check if notifications are enabled
      _notificationsEnabled = await _notificationService.areNotificationsEnabled();
      
      // Get saved reminder time
      final savedTime = await _notificationService.getSavedReminderTime();
      if (savedTime != null) {
        _reminderTime = savedTime;
      }
      
      // Get saved reminder days
      final savedDays = await _notificationService.getSavedReminderDays();
      if (savedDays.isNotEmpty) {
        _selectedDays = savedDays;
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Fehler beim Laden der Benachrichtigungseinstellungen: $e';
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    try {
      if (value) {
        // Request permissions when enabling notifications
        final granted = await _notificationService.requestPermissions();
        
        if (!granted) {
          setState(() {
            _errorMessage = 'Benachrichtigungsberechtigungen wurden nicht erteilt';
          });
          return;
        }
      }
      
      await _notificationService.setNotificationsEnabled(value);
      
      setState(() {
        _notificationsEnabled = value;
      });
      
      if (value && _selectedDays.isNotEmpty) {
        // Schedule reminders if days are selected
        await _notificationService.scheduleDailyReminder(_reminderTime, _selectedDays);
      } else if (!value) {
        // Cancel all reminders when disabling notifications
        await _notificationService.cancelAllReminders();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Ändern der Benachrichtigungseinstellungen: $e';
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    
    if (pickedTime != null) {
      setState(() {
        _reminderTime = pickedTime;
      });
      
      if (_notificationsEnabled && _selectedDays.isNotEmpty) {
        await _notificationService.scheduleDailyReminder(_reminderTime, _selectedDays);
      }
    }
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
    
    if (_notificationsEnabled && _selectedDays.isNotEmpty) {
      _notificationService.scheduleDailyReminder(_reminderTime, _selectedDays);
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      await _notificationService.showNotification(
        title: 'Test-Benachrichtigung',
        body: 'Dies ist eine Test-Benachrichtigung von Konsum Tracker Pro',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test-Benachrichtigung gesendet'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler beim Senden der Test-Benachrichtigung: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Benachrichtigungen'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: Spacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage.isNotEmpty) ...[
                    _buildErrorCard(context, isDark),
                    Spacing.verticalSpaceMd,
                  ],
                  
                  _buildNotificationsToggle(context, isDark),
                  Spacing.verticalSpaceLg,
                  
                  if (_notificationsEnabled) ...[
                    _buildReminderTimeSection(context, isDark),
                    Spacing.verticalSpaceLg,
                    _buildReminderDaysSection(context, isDark),
                    Spacing.verticalSpaceLg,
                    _buildTestNotificationSection(context, isDark),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildErrorCard(BuildContext context, bool isDark) {
    return GlassCard(
      borderColor: DesignTokens.errorRed.withOpacity(0.3),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: DesignTokens.errorRed,
            size: Spacing.iconMd,
          ),
          Spacing.horizontalSpaceMd,
          Expanded(
            child: Text(
              _errorMessage,
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

  Widget _buildNotificationsToggle(BuildContext context, bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benachrichtigungen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceMd,
          SwitchListTile(
            title: const Text('Benachrichtigungen aktivieren'),
            subtitle: const Text(
              'Erhalten Sie Erinnerungen für Ihre Einträge',
            ),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            secondary: Icon(
              Icons.notifications_rounded,
              color: DesignTokens.primaryIndigo,
            ),
          ),
          if (!_notificationsEnabled) ...[
            const Divider(),
            Padding(
              padding: Spacing.paddingMd,
              child: Text(
                'Aktivieren Sie Benachrichtigungen, um Erinnerungen für Ihre Einträge zu erhalten.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
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

  Widget _buildReminderTimeSection(BuildContext context, bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Erinnerungszeit',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceMd,
          ListTile(
            title: const Text('Uhrzeit'),
            subtitle: Text(
              'Täglich um ${_reminderTime.format(context)}',
            ),
            leading: Icon(
              Icons.access_time_rounded,
              color: DesignTokens.accentCyan,
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: _selectTime,
          ),
          const Divider(),
          Padding(
            padding: Spacing.paddingMd,
            child: Text(
              'Wählen Sie die Uhrzeit, zu der Sie täglich erinnert werden möchten.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
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

  Widget _buildReminderDaysSection(BuildContext context, bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Erinnerungstage',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceMd,
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: List.generate(7, (index) {
              final day = index + 1; // 1 = Monday, 7 = Sunday
              final isSelected = _selectedDays.contains(day);
              final dayName = _getDayName(day, short: true);
              
              return GestureDetector(
                onTap: () => _toggleDay(day),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DesignTokens.primaryIndigo.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: Spacing.borderRadiusFull,
                    border: Border.all(
                      color: isSelected
                          ? DesignTokens.primaryIndigo
                          : (isDark
                              ? DesignTokens.glassBorderDark
                              : DesignTokens.glassBorderLight),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? DesignTokens.primaryIndigo : null,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          Spacing.verticalSpaceMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDays = [1, 2, 3, 4, 5, 6, 7];
                  });
                  
                  if (_notificationsEnabled) {
                    _notificationService.scheduleDailyReminder(_reminderTime, _selectedDays);
                  }
                },
                child: const Text('Alle auswählen'),
              ),
              Spacing.horizontalSpaceSm,
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDays = [];
                  });
                  
                  if (_notificationsEnabled) {
                    _notificationService.cancelAllReminders();
                  }
                },
                child: const Text('Keine auswählen'),
              ),
            ],
          ),
          const Divider(),
          Padding(
            padding: Spacing.paddingMd,
            child: Text(
              'Wählen Sie die Tage aus, an denen Sie erinnert werden möchten.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
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

  Widget _buildTestNotificationSection(BuildContext context, bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test-Benachrichtigung',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceMd,
          Text(
            'Senden Sie eine Test-Benachrichtigung, um zu überprüfen, ob Benachrichtigungen korrekt funktionieren.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Spacing.verticalSpaceMd,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendTestNotification,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Test-Benachrichtigung senden'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primaryIndigo,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 600),
    ).slideY(
      begin: 0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  String _getDayName(int day, {bool short = false}) {
    if (short) {
      switch (day) {
        case 1: return 'Mo';
        case 2: return 'Di';
        case 3: return 'Mi';
        case 4: return 'Do';
        case 5: return 'Fr';
        case 6: return 'Sa';
        case 7: return 'So';
        default: return '';
      }
    } else {
      switch (day) {
        case 1: return 'Montag';
        case 2: return 'Dienstag';
        case 3: return 'Mittwoch';
        case 4: return 'Donnerstag';
        case 5: return 'Freitag';
        case 6: return 'Samstag';
        case 7: return 'Sonntag';
        default: return '';
      }
    }
  }
}