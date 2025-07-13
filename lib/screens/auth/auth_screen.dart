import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';
import '../../services/auth_service.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../../widgets/glass_card.dart';
import '../main_navigation.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isPINEnabled = false;
  List<String> _availableBiometrics = [];
  String _errorMessage = '';
  
  // PIN input
  final _pinController = TextEditingController();
  final List<FocusNode> _pinFocusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _pinControllers = List.generate(4, (_) => TextEditingController());
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _checkAuthSettings();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_animationController);
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    for (final controller in _pinControllers) {
      controller.dispose();
    }
    for (final node in _pinFocusNodes) {
      node.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Check if biometric authentication is available
      _isBiometricAvailable = await _authService.isBiometricAvailable();
      
      if (_isBiometricAvailable) {
        _availableBiometrics = await _authService.getAvailableBiometrics();
      }
      
      // Check if biometric authentication is enabled
      _isBiometricEnabled = await _authService.isBiometricEnabled();
      
      // Check if PIN is set
      _isPINEnabled = await _authService.isPINSet();
      
      setState(() {
        _isLoading = false;
      });
      
      // If biometric is enabled, authenticate immediately
      if (_isBiometricEnabled && _isBiometricAvailable) {
        _authenticateWithBiometrics();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Fehler beim Laden der Authentifizierungseinstellungen: $e';
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final authenticated = await _authService.authenticateWithBiometrics();
      
      if (authenticated && mounted) {
        _navigateToApp();
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Biometrische Authentifizierung fehlgeschlagen';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler bei der biometrischen Authentifizierung: $e';
        });
      }
    }
  }

  Future<void> _authenticateWithPIN() async {
    final pin = _pinControllers.map((c) => c.text).join();
    
    try {
      final authenticated = await _authService.authenticateWithPIN(pin);
      
      if (authenticated && mounted) {
        _navigateToApp();
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Falscher PIN';
          for (final controller in _pinControllers) {
            controller.clear();
          }
          _pinFocusNodes[0].requestFocus();
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler bei der PIN-Authentifizierung: $e';
        });
        _animationController.forward();
      }
    }
  }

  void _navigateToApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainNavigation(),
      ),
    );
  }

  void _skipAuthentication() {
    _navigateToApp();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
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
          child: Center(
            child: SingleChildScrollView(
              padding: Spacing.paddingMd,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(context),
                  Spacing.verticalSpaceXl,
                  
                  if (_isLoading)
                    _buildLoadingState(context)
                  else if (_isBiometricEnabled || _isPINEnabled)
                    _buildAuthenticationOptions(context, isDark)
                  else
                    _buildNoAuthSetup(context, isDark),
                    
                  if (_errorMessage.isNotEmpty) ...[
                    Spacing.verticalSpaceMd,
                    _buildErrorMessage(context),
                  ],
                  
                  Spacing.verticalSpaceXl,
                  
                  // Skip button (only in development)
                  TextButton(
                    onPressed: _skipAuthentication,
                    child: const Text('Überspringen (nur für Entwicklung)'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.security_rounded,
          size: 80,
          color: Colors.white,
        ),
        Spacing.verticalSpaceMd,
        Text(
          'Konsum Tracker Pro',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          'Bitte authentifizieren Sie sich',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    ).animate().fadeIn(
      duration: DesignTokens.animationSlow,
    ).slideY(
      begin: -0.2,
      end: 0,
      duration: DesignTokens.animationSlow,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: Spacing.paddingLg,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: Spacing.borderRadiusLg,
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          Spacing.verticalSpaceMd,
          Text(
            'Lade Authentifizierungsoptionen...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticationOptions(BuildContext context, bool isDark) {
    return GlassCard(
      child: Column(
        children: [
          if (_isBiometricEnabled && _isBiometricAvailable) ...[
            _buildBiometricOption(context),
          ],
          
          if (_isPINEnabled) ...[
            if (_isBiometricEnabled && _isBiometricAvailable)
              const Divider(height: 32),
            _buildPINInput(context),
          ],
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 300),
    ).slideY(
      begin: 0.2,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Widget _buildBiometricOption(BuildContext context) {
    final biometricName = _availableBiometrics.isNotEmpty
        ? _availableBiometrics.first
        : 'Biometrie';

    return Column(
      children: [
        Icon(
          _getBiometricIcon(),
          size: 60,
          color: DesignTokens.primaryIndigo,
        ),
        Spacing.verticalSpaceMd,
        Text(
          'Mit $biometricName anmelden',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacing.verticalSpaceMd,
        ElevatedButton.icon(
          onPressed: _authenticateWithBiometrics,
          icon: Icon(_getBiometricIcon(small: true)),
          label: Text('Mit $biometricName fortfahren'),
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignTokens.primaryIndigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPINInput(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Column(
        children: [
          Text(
            'PIN eingeben',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                width: 50,
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  controller: _pinControllers[index],
                  focusNode: _pinFocusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  obscureText: true,
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: DesignTokens.primaryIndigo,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: DesignTokens.primaryIndigo,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                  ),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 3) {
                      _pinFocusNodes[index + 1].requestFocus();
                    }
                    
                    // Check if all fields are filled
                    if (index == 3 && value.isNotEmpty) {
                      _authenticateWithPIN();
                    }
                  },
                ),
              );
            }),
          ),
          Spacing.verticalSpaceMd,
          ElevatedButton(
            onPressed: _authenticateWithPIN,
            child: const Text('Bestätigen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryIndigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAuthSetup(BuildContext context, bool isDark) {
    return GlassCard(
      child: Column(
        children: [
          Icon(
            Icons.lock_open_rounded,
            size: 60,
            color: DesignTokens.warningYellow,
          ),
          Spacing.verticalSpaceMd,
          Text(
            'Keine Sicherheitseinstellungen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceSm,
          Text(
            'Sie haben keine App-Sperre aktiviert. Sie können dies in den Sicherheitseinstellungen tun.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Spacing.verticalSpaceMd,
          ElevatedButton(
            onPressed: _navigateToApp,
            child: const Text('Fortfahren'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryIndigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.md,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 300),
    ).slideY(
      begin: 0.2,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Container(
      padding: Spacing.paddingMd,
      decoration: BoxDecoration(
        color: DesignTokens.errorRed.withOpacity(0.1),
        borderRadius: Spacing.borderRadiusMd,
        border: Border.all(
          color: DesignTokens.errorRed.withOpacity(0.3),
          width: 1,
        ),
      ),
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
      begin: 0.2,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  IconData _getBiometricIcon({bool small = false}) {
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