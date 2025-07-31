import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/xtc_substance.dart';
import '../../models/entry.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/xtc_color_picker.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../../utils/service_locator.dart';
import '../../use_cases/entry_use_cases.dart';

/// Dialog for creating XTC entries with specialized fields
class XTCEntryDialog extends StatefulWidget {
  const XTCEntryDialog({super.key});

  @override
  State<XTCEntryDialog> createState() => _XTCEntryDialogState();
}

class _XTCEntryDialogState extends State<XTCEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _mengeController = TextEditingController();
  final _gewichtController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Form state
  XTCForm _selectedForm = XTCForm.rechteck;
  XTCContent _selectedInhalt = XTCContent.mdma;
  bool _bruchrillen = false;
  Color _selectedColor = Colors.blue;
  DateTime _selectedDateTime = DateTime.now();
  bool _isSaving = false;
  String? _errorMessage;

  // Use Cases
  late final CreateEntryUseCase _createEntryUseCase;

  @override
  void initState() {
    super.initState();
    _createEntryUseCase = ServiceLocator.get<CreateEntryUseCase>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mengeController.dispose();
    _gewichtController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // Create XTC substance data
      final xtcSubstance = XTCSubstance.create(
        name: _nameController.text.trim(),
        form: _selectedForm,
        bruchrillen: _bruchrillen,
        inhalt: _selectedInhalt,
        menge: double.tryParse(_mengeController.text.replaceAll(',', '.')) ?? 0.0,
        farbe: _selectedColor,
        gewicht: _gewichtController.text.trim().isNotEmpty 
            ? double.tryParse(_gewichtController.text.replaceAll(',', '.'))
            : null,
      );

      // Create entry with XTC-specific substance ID and data
      await _createEntryUseCase.execute(
        substanceId: 'xtc_${xtcSubstance.id}', // Special XTC prefix
        dosage: xtcSubstance.menge,
        unit: 'mg',
        dateTime: _selectedDateTime,
        notes: _buildXTCNotes(xtcSubstance),
      );
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('XTC Eintrag erfolgreich gespeichert'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Speichern: $e';
        _isSaving = false;
      });
    }
  }

  String _buildXTCNotes(XTCSubstance xtcSubstance) {
    final notes = <String>[];
    
    notes.add('XTC/Ecstasy: ${xtcSubstance.name}');
    notes.add('Form: ${xtcSubstance.formDisplayName}');
    notes.add('Inhalt: ${xtcSubstance.inhaltDisplayName}');
    notes.add('Bruchrillen: ${xtcSubstance.bruchrillenlDisplayName}');
    notes.add('Farbe: RGB(${xtcSubstance.farbe.red}, ${xtcSubstance.farbe.green}, ${xtcSubstance.farbe.blue})');
    
    if (xtcSubstance.gewicht != null) {
      notes.add('Gewicht: ${xtcSubstance.formattedGewicht}');
    }
    
    if (_notesController.text.trim().isNotEmpty) {
      notes.add('Zusätzliche Notizen: ${_notesController.text.trim()}');
    }
    
    return notes.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.9,
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(context, theme),
            Expanded(
              child: _buildContent(context, theme),
            ),
            _buildActionButtons(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: Spacing.paddingMd,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DesignTokens.accentPink.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.medication_rounded,
              color: DesignTokens.accentPink,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'XTC Eintrag',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Ecstasy/MDMA Substanz erfassen',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
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

  Widget _buildContent(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: Spacing.paddingMd,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null) ...[
              _buildErrorCard(context),
              Spacing.verticalSpaceMd,
            ],
            
            _buildNameSection(context, theme),
            Spacing.verticalSpaceMd,
            
            _buildFormSection(context, theme),
            Spacing.verticalSpaceMd,
            
            _buildInhaltSection(context, theme),
            Spacing.verticalSpaceMd,
            
            _buildMengeSection(context, theme),
            Spacing.verticalSpaceMd,
            
            _buildColorSection(context, theme),
            Spacing.verticalSpaceMd,
            
            _buildBruchrillenlSection(context, theme),
            Spacing.verticalSpaceMd,
            
            _buildGewichtSection(context, theme),
            Spacing.verticalSpaceMd,
            
            _buildDateTimeSection(context, theme),
            Spacing.verticalSpaceMd,
            
            _buildNotesSection(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
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
    );
  }

  Widget _buildNameSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Name',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GlassCard(
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Substanzname (z.B. Blue Punisher)',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.label_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Bitte geben Sie einen Namen ein';
              }
              return null;
            },
          ),
        ),
      ],
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 200),
    );
  }

  Widget _buildFormSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Form',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GlassCard(
          child: DropdownButtonFormField<XTCForm>(
            value: _selectedForm,
            decoration: const InputDecoration(
              labelText: 'Pillenform auswählen',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: XTCForm.values.map((form) {
              return DropdownMenuItem<XTCForm>(
                value: form,
                child: Row(
                  children: [
                    Icon(
                      _getFormIcon(form),
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(_getFormDisplayName(form)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedForm = value!;
              });
            },
          ),
        ),
      ],
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 300),
    );
  }

  Widget _buildInhaltSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inhalt',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GlassCard(
          child: DropdownButtonFormField<XTCContent>(
            value: _selectedInhalt,
            decoration: const InputDecoration(
              labelText: 'Wirkstoff auswählen',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.science_outlined),
            ),
            items: XTCContent.values.map((content) {
              return DropdownMenuItem<XTCContent>(
                value: content,
                child: Row(
                  children: [
                    Icon(
                      _getInhaltIcon(content),
                      size: 20,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(_getInhaltDisplayName(content)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedInhalt = value!;
              });
            },
          ),
        ),
      ],
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 400),
    );
  }

  Widget _buildMengeSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menge',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GlassCard(
          child: TextFormField(
            controller: _mengeController,
            decoration: const InputDecoration(
              labelText: 'Dosierung in mg',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.monitor_weight_outlined),
              suffixText: 'mg',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Bitte geben Sie eine Dosierung ein';
              }
              final menge = double.tryParse(value.replaceAll(',', '.'));
              if (menge == null || menge <= 0) {
                return 'Bitte geben Sie eine gültige Dosierung ein';
              }
              return null;
            },
          ),
        ),
      ],
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 500),
    );
  }

  Widget _buildColorSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farbe',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GlassCard(
          child: Padding(
            padding: Spacing.paddingMd,
            child: XTCColorPicker(
              selectedColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
          ),
        ),
      ],
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 600),
    );
  }

  Widget _buildBruchrillenlSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bruchrillen',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GlassCard(
          child: Padding(
            padding: Spacing.paddingMd,
            child: Row(
              children: [
                Icon(
                  _bruchrillen ? Icons.call_split_rounded : Icons.panorama_fish_eye_rounded,
                  color: _bruchrillen ? DesignTokens.successGreen : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hat die Pille Bruchrillen?',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _bruchrillen ? 'Ja, Bruchrillen vorhanden' : 'Nein, keine Bruchrillen',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _bruchrillen,
                  onChanged: (value) {
                    setState(() {
                      _bruchrillen = value;
                    });
                  },
                  activeColor: DesignTokens.successGreen,
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 700),
    );
  }

  Widget _buildGewichtSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gewicht (optional)',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GlassCard(
          child: TextFormField(
            controller: _gewichtController,
            decoration: const InputDecoration(
              labelText: 'Gesamtgewicht der Pille',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.scale_outlined),
              suffixText: 'mg',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final gewicht = double.tryParse(value.replaceAll(',', '.'));
                if (gewicht == null || gewicht <= 0) {
                  return 'Bitte geben Sie ein gültiges Gewicht ein';
                }
              }
              return null;
            },
          ),
        ),
      ],
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 800),
    );
  }

  Widget _buildDateTimeSection(BuildContext context, ThemeData theme) {
    final dateFormat = DateFormat('dd.MM.yyyy', 'de_DE');
    final timeFormat = DateFormat('HH:mm', 'de_DE');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datum & Uhrzeit',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GlassCard(
                onTap: () => _selectDate(context),
                child: Padding(
                  padding: Spacing.paddingMd,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: DesignTokens.primaryIndigo,
                        size: Spacing.iconMd,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Datum',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              dateFormat.format(_selectedDateTime),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassCard(
                onTap: () => _selectTime(context),
                child: Padding(
                  padding: Spacing.paddingMd,
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: DesignTokens.accentCyan,
                        size: Spacing.iconMd,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Uhrzeit',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              timeFormat.format(_selectedDateTime),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 900),
    );
  }

  Widget _buildNotesSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zusätzliche Notizen (optional)',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GlassCard(
          child: TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Weitere Informationen...',
              border: InputBorder.none,
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            maxLength: 500,
          ),
        ),
      ],
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 1000),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Container(
      padding: Spacing.paddingMd,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Abbrechen'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveEntry,
              icon: _isSaving 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Speichern...' : 'Speichern'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.accentPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 1100),
    );
  }

  // Helper methods
  IconData _getFormIcon(XTCForm form) {
    switch (form) {
      case XTCForm.rechteck:
      case XTCForm.viereck:
        return Icons.rectangle_outlined;
      case XTCForm.stern:
        return Icons.star_outline_rounded;
      case XTCForm.kreis:
        return Icons.circle_outlined;
      case XTCForm.dreieck:
        return Icons.change_history_outlined;
      case XTCForm.blume:
        return Icons.local_florist_outlined;
      case XTCForm.oval:
        return Icons.oval_outlined;
      case XTCForm.pillenSpezifisch:
        return Icons.medication_outlined;
    }
  }

  String _getFormDisplayName(XTCForm form) {
    switch (form) {
      case XTCForm.rechteck:
        return 'Rechteck';
      case XTCForm.stern:
        return 'Stern';
      case XTCForm.kreis:
        return 'Kreis';
      case XTCForm.dreieck:
        return 'Dreieck';
      case XTCForm.blume:
        return 'Blume';
      case XTCForm.oval:
        return 'Oval';
      case XTCForm.viereck:
        return 'Viereck';
      case XTCForm.pillenSpezifisch:
        return 'Pillen-Spezifisch';
    }
  }

  IconData _getInhaltIcon(XTCContent content) {
    switch (content) {
      case XTCContent.mdma:
        return Icons.psychology_outlined;
      case XTCContent.mda:
        return Icons.science_outlined;
      case XTCContent.amphetamin:
        return Icons.flash_on_outlined;
      case XTCContent.unbekannt:
        return Icons.help_outline_rounded;
    }
  }

  String _getInhaltDisplayName(XTCContent content) {
    switch (content) {
      case XTCContent.mdma:
        return 'MDMA';
      case XTCContent.mda:
        return 'MDA';
      case XTCContent.amphetamin:
        return 'Amph.';
      case XTCContent.unbekannt:
        return 'Unbekannt';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (date != null) {
      setState(() {
        _selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (time != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }
}