import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/header_bar.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isAppLockEnabled = false;
  bool _isPINSet = false;
  List<String> _availableBiometrics = [];
  String _errorMessage = '';
  
  // PIN setup
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isPINVisible = false;

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _loadSecuritySettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Check if biometric authentication is available
      _isBiometricAvailable = await _authService.isBiometricAvailable();
      
      // Get available biometric types
      if (_isBiometricAvailable) {
        _availableBiometrics = await _authService.getAvailableBiometrics();
      }
      
      // Check if biometric authentication is enabled
      _isBiometricEnabled = await _authService.isBiometricEnabled();
      
      // Check if app lock is enabled
      _isAppLockEnabled = await _authService.isAppLockEnabled();
      
      // Check if PIN is set
      _isPINSet = await _authService.isPINSet();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Fehler beim Laden der Sicherheitseinstellungen: $e';
      });
    }
  }

  Future<void> _toggleBiometricAuth(bool value) async {
    try {
      if (value && !_isPINSet) {
        // PIN must be set before enabling biometric auth - show dialog
        _showSetPINDialog();
        return;
      }
      
      await _authService.setBiometricEnabled(value);
      
      setState(() {
        _isBiometricEnabled = value;
      });
      
      if (value) {
        // Also enable app lock when enabling biometric auth
        await _authService.setAppLockEnabled(true);
        setState(() {
          _isAppLockEnabled = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Ändern der biometrischen Authentifizierung: $e';
      });
    }
  }

  Future<void> _toggleAppLock(bool value) async {
    try {
      if (value && !_isPINSet) {
        // PIN must be set before enabling app lock - show dialog
        _showSetPINDialog();
        return;
      }
      
      await _authService.setAppLockEnabled(value);
      
      setState(() {
        _isAppLockEnabled = value;
      });
      
      if (!value && _isBiometricEnabled) {
        // Disable biometric auth when disabling app lock
        await _authService.setBiometricEnabled(false);
        setState(() {
          _isBiometricEnabled = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Ändern der App-Sperre: $e';
      });
    }
  }

  void _showSetPINDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('PIN einrichten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bitte richten Sie einen PIN-Code ein, um die App-Sperre zu aktivieren.',
            ),
            Spacing.verticalSpaceMd,
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(
                labelText: 'PIN-Code (4-6 Ziffern)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              obscureText: !_isPINVisible,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            Spacing.verticalSpaceMd,
            TextField(
              controller: _confirmPinController,
              decoration: const InputDecoration(
                labelText: 'PIN-Code bestätigen',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              obscureText: !_isPINVisible,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _isPINVisible,
                  onChanged: (value) {
                    setState(() {
                      _isPINVisible = value ?? false;
                    });
                  },
                ),
                const Text('PIN anzeigen'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _pinController.clear();
              _confirmPinController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => _setPIN(context),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  Future<void> _setPIN(BuildContext context) async {
    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;
    
    if (pin.isEmpty || !_authService.isValidPIN(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte geben Sie einen gültigen PIN-Code ein (4-6 Ziffern)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (pin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Die PIN-Codes stimmen nicht überein'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      await _authService.setPinCode(pin);
      
      setState(() {
        _isPINSet = true;
      });
      
      // Enable app lock
      await _authService.setAppLockEnabled(true);
      setState(() {
        _isAppLockEnabled = true;
      });
      
      // Close dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN-Code erfolgreich eingerichtet'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Einrichten des PIN-Codes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changePIN() async {
    _pinController.clear();
    _confirmPinController.clear();
    _showSetPINDialog();
  }

  Future<void> _resetSecurity() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sicherheitseinstellungen zurücksetzen'),
        content: const Text(
          'Sind Sie sicher, dass Sie alle Sicherheitseinstellungen zurücksetzen möchten? '
          'Dies deaktiviert die App-Sperre und löscht Ihren PIN-Code.',
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
            child: const Text('Zurücksetzen'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _authService.clearAuthSettings();
      
      setState(() {
        _isBiometricEnabled = false;
        _isAppLockEnabled = false;
        _isPINSet = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sicherheitseinstellungen erfolgreich zurückgesetzt'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler beim Zurücksetzen der Sicherheitseinstellungen: $e';
        });
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
          HeaderBar(
            title: 'Sicherheitseinstellungen',
            subtitle: 'App-Sperre und Biometrie',
            showBackButton: true,
            showLightningIcon: true,
          ),
          Expanded(
            child: _isLoading
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
                        
                        _buildAppLockSection(context, isDark),
                        Spacing.verticalSpaceLg,
                        
                        if (_isBiometricAvailable) ...[
                          _buildBiometricSection(context, isDark),
                          Spacing.verticalSpaceLg,
                        ],
                        
                        _buildPINSection(context, isDark),
                        Spacing.verticalSpaceLg,
                        _buildResetSection(context, isDark),
                      ],
                    ),
                  ),
          ),
        ],
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

  Widget _buildAppLockSection(BuildContext context, bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App-Sperre',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceMd,
          SwitchListTile(
            title: const Text('App-Sperre aktivieren'),
            subtitle: const Text(
              'Schützt die App vor unbefugtem Zugriff',
            ),
            value: _isAppLockEnabled,
            onChanged: _toggleAppLock,
            secondary: Icon(
              Icons.lock_rounded,
              color: DesignTokens.primaryIndigo,
            ),
          ),
          if (_isAppLockEnabled) ...[
            const Divider(),
            Padding(
              padding: Spacing.paddingMd,
              child: Text(
                'Die App-Sperre wird aktiviert, wenn die App in den Hintergrund wechselt oder geschlossen wird.',
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

  Widget _buildBiometricSection(BuildContext context, bool isDark) {
    final biometricName = _availableBiometrics.isNotEmpty
        ? _availableBiometrics.first
        : 'Biometrie';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biometrische Authentifizierung',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceMd,
          SwitchListTile(
            title: Text('$biometricName verwenden'),
            subtitle: Text(
              'Entsperren Sie die App mit $biometricName',
            ),
            value: _isBiometricEnabled,
            onChanged: _isBiometricAvailable ? _toggleBiometricAuth : null,
            secondary: Icon(
              _getBiometricIcon(),
              color: DesignTokens.accentCyan,
            ),
          ),
          if (_isBiometricAvailable) ...[
            const Divider(),
            Padding(
              padding: Spacing.paddingMd,
              child: Text(
                'Verfügbare biometrische Methoden: ${_availableBiometrics.join(", ")}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ),
          ] else ...[
            const Divider(),
            Padding(
              padding: Spacing.paddingMd,
              child: Text(
                'Biometrische Authentifizierung ist auf diesem Gerät nicht verfügbar.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: DesignTokens.warningYellow,
                ),
              ),
            ),
          ],
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

  Widget _buildPINSection(BuildContext context, bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PIN-Code',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceMd,
          ListTile(
            title: Text(_isPINSet ? 'PIN-Code ändern' : 'PIN-Code einrichten'),
            subtitle: Text(
              _isPINSet
                  ? 'Aktuellen PIN-Code ändern'
                  : 'Richten Sie einen PIN-Code für die App-Sperre ein',
            ),
            leading: Icon(
              Icons.pin_rounded,
              color: DesignTokens.accentEmerald,
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: _changePIN,
          ),
          const Divider(),
          Padding(
            padding: Spacing.paddingMd,
            child: Text(
              _isPINSet
                  ? 'Ihr PIN-Code ist eingerichtet und wird für die App-Sperre verwendet.'
                  : 'Ein PIN-Code ist erforderlich, um die App-Sperre zu aktivieren.',
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

  Widget _buildResetSection(BuildContext context, bool isDark) {
    return GlassCard(
      borderColor: DesignTokens.errorRed.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sicherheitseinstellungen zurücksetzen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: DesignTokens.errorRed,
            ),
          ),
          Spacing.verticalSpaceMd,
          Text(
            'Setzen Sie alle Sicherheitseinstellungen zurück, einschließlich App-Sperre, biometrischer Authentifizierung und PIN-Code.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Spacing.verticalSpaceMd,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _resetSecurity,
              icon: const Icon(Icons.restore_rounded),
              label: const Text('Alle Sicherheitseinstellungen zurücksetzen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.errorRed,
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

  IconData _getBiometricIcon() {
    if (_availableBiometrics.isEmpty) return Icons.fingerprint;
    
    if (_availableBiometrics.contains('Face ID')) {
      return Icons.face_rounded;
    } else if (_availableBiometrics.contains('Fingerabdruck')) {
      return Icons.fingerprint;
    } else if (_availableBiometrics.contains('Iris')) {
      return Icons.remove_red_eye_rounded;
    } else {
      return Icons.fingerprint;
    }
  }
}