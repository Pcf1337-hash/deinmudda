import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/entry.dart';
import '../services/timer_service.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';

class ActiveTimerBar extends StatefulWidget {
  final Entry timer;
  final VoidCallback? onTap;

  const ActiveTimerBar({
    super.key,
    required this.timer,
    this.onTap,
  });

  @override
  State<ActiveTimerBar> createState() => _ActiveTimerBarState();
}

class _ActiveTimerBarState extends State<ActiveTimerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  final TextEditingController _timerInputController = TextEditingController();
  final TimerService _timerService = TimerService();
  final FocusNode _focusNode = FocusNode();
  
  bool _showTimerInput = false;
  final List<int> _suggestionMinutes = [15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timerInputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = widget.timer.timerProgress;
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              margin: const EdgeInsets.all(Spacing.md),
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        colors: [
                          DesignTokens.accentCyan.withOpacity(0.1),
                          DesignTokens.accentCyan.withOpacity(0.05),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          DesignTokens.accentCyan.withOpacity(0.15),
                          DesignTokens.accentCyan.withOpacity(0.08),
                        ],
                      ),
                borderRadius: Spacing.borderRadiusLg,
                border: Border.all(
                  color: DesignTokens.accentCyan.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.accentCyan.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(Spacing.sm),
                        decoration: BoxDecoration(
                          color: DesignTokens.accentCyan.withOpacity(0.2),
                          borderRadius: Spacing.borderRadiusMd,
                        ),
                        child: Icon(
                          Icons.timer_rounded,
                          color: DesignTokens.accentCyan,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.timer.substanceName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: DesignTokens.accentCyan,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Timer läuft',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.timer.formattedRemainingTime,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: DesignTokens.accentCyan,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showTimerInput = !_showTimerInput;
                          });
                        },
                        icon: Icon(
                          _showTimerInput ? Icons.keyboard_arrow_up : Icons.edit_rounded,
                          color: DesignTokens.accentCyan,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: DesignTokens.accentCyan.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(DesignTokens.accentCyan),
                    minHeight: 4,
                  ),
                  
                  // Timer input field with animation
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _showTimerInput ? _buildTimerInputField() : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerInputField() {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: DesignTokens.accentCyan.withOpacity(0.05),
        borderRadius: Spacing.borderRadiusMd,
        border: Border.all(
          color: DesignTokens.accentCyan.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timer anpassen',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: DesignTokens.accentCyan,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          
          // Custom time input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _timerInputController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: InputDecoration(
                    hintText: 'z.B. 64',
                    prefixIcon: Icon(Icons.timer_outlined, color: DesignTokens.accentCyan),
                    suffixText: 'Min',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: DesignTokens.accentCyan.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: DesignTokens.accentCyan),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: _onTimerInputChanged,
                  onSubmitted: (_) => _updateTimerDuration(),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              ElevatedButton(
                onPressed: _updateTimerDuration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.accentCyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
          
          // Real-time conversion display
          if (_timerInputController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: Text(
                'Entspricht: ${_formatInputTime(_timerInputController.text)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: DesignTokens.accentCyan,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          
          const SizedBox(height: Spacing.sm),
          
          // Suggestion chips
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _suggestionMinutes.map((minutes) {
              return GestureDetector(
                onTap: () {
                  _timerInputController.text = minutes.toString();
                  _updateTimerDuration();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: DesignTokens.accentCyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: DesignTokens.accentCyan.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${minutes}min',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: DesignTokens.accentCyan,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _onTimerInputChanged(String value) {
    setState(() {}); // Trigger rebuild to update conversion display
  }

  String _formatInputTime(String input) {
    final minutes = int.tryParse(input);
    if (minutes == null || minutes <= 0) return '';
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '$hours Std${remainingMinutes > 0 ? ' $remainingMinutes Min' : ''}';
    } else {
      return '$minutes Min';
    }
  }

  Future<void> _updateTimerDuration() async {
    final inputText = _timerInputController.text.trim();
    if (inputText.isEmpty) return;
    
    final minutes = int.tryParse(inputText);
    if (minutes == null || minutes <= 0) {
      _showErrorMessage('Bitte gib eine gültige Anzahl Minuten ein');
      return;
    }
    
    try {
      // Update the timer with new duration
      final newDuration = Duration(minutes: minutes);
      await _timerService.updateTimerDuration(widget.timer, newDuration);
      
      // Hide input field and clear text
      setState(() {
        _showTimerInput = false;
        _timerInputController.clear();
      });
      
      // Unfocus the text field
      _focusNode.unfocus();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Timer auf ${_formatInputTime(inputText)} angepasst'),
            backgroundColor: DesignTokens.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _showErrorMessage('Fehler beim Aktualisieren des Timers: $e');
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: DesignTokens.errorRed,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}