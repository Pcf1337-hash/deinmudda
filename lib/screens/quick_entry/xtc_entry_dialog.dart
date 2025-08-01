import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/xtc_entry.dart';
import '../../models/entry.dart';
import '../../models/substance.dart';
import '../../widgets/xtc_color_picker.dart';
import '../../widgets/xtc_size_selector.dart';
import '../../widgets/glass_card.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../../utils/service_locator.dart';
import '../../use_cases/entry_use_cases.dart';
import '../../interfaces/service_interfaces.dart';
import '../../services/xtc_entry_service.dart';

class XtcEntryDialog extends StatefulWidget {
  final bool isQuickEntry; // New parameter to determine if this is for quick entry creation
  
  const XtcEntryDialog({
    super.key,
    this.isQuickEntry = false,
  });

  @override
  State<XtcEntryDialog> createState() => _XtcEntryDialogState();
}

class _XtcEntryDialogState extends State<XtcEntryDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Form controllers
  final _substanceNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Form state
  XtcForm _selectedForm = XtcForm.rechteck;
  int _bruchrillienAnzahl = 0; // Changed from boolean to int (0-4)
  XtcContent _selectedContent = XtcContent.mdma;
  XtcSize _selectedSize = XtcSize.full;
  Color _selectedColor = Colors.pink;
  DateTime _selectedDateTime = DateTime.now();
  bool _isDosageUnknown = false;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  bool _startTimer = false; // XTC doesn't typically have timer by default

  // Services
  late final CreateEntryUseCase _createEntryUseCase;
  late final CreateEntryWithTimerUseCase _createEntryWithTimerUseCase;
  late final ITimerService _timerService;
  late final XtcEntryService _xtcEntryService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    try {
      _createEntryUseCase = ServiceLocator.get<CreateEntryUseCase>();
      _createEntryWithTimerUseCase = ServiceLocator.get<CreateEntryWithTimerUseCase>();
      _timerService = ServiceLocator.get<ITimerService>();
      _xtcEntryService = ServiceLocator.get<XtcEntryService>();
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Initialisieren der Services: $e';
      });
      // Debug information
      print('🚨 XtcEntryDialog service initialization failed: $e');
      print(ServiceLocator.getRegistrationInfo());
      rethrow;
    }
  }

  @override
  void dispose() {
    _substanceNameController.dispose();
    _dosageController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // Parse dosage if not unknown
      double? dosageMg;
      if (!_isDosageUnknown && _dosageController.text.isNotEmpty) {
        dosageMg = double.tryParse(_dosageController.text.replaceAll(',', '.'));
      }

      // Parse weight if provided
      double? weightGrams;
      if (_weightController.text.isNotEmpty) {
        weightGrams = double.tryParse(_weightController.text.replaceAll(',', '.'));
      }

      // Create XTC entry
      final xtcEntry = XtcEntry.create(
        substanceName: _substanceNameController.text.trim(),
        form: _selectedForm,
        bruchrillienAnzahl: _bruchrillienAnzahl,
        content: _selectedContent,
        size: _selectedSize,
        dosageMg: dosageMg,
        color: _selectedColor,
        weightGrams: weightGrams,
        dateTime: widget.isQuickEntry ? DateTime.now() : _selectedDateTime, // Use current time for quick entries
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      // Save using the XTC service
      await _xtcEntryService.saveXtcEntry(xtcEntry, startTimer: _startTimer);

      if (mounted) {
        Navigator.of(context).pop(xtcEntry); // Return the XTC entry
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_startTimer 
                ? 'XTC-Eintrag mit Timer erfolgreich gespeichert' 
                : 'XTC-Eintrag erfolgreich gespeichert'),
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

  String _buildXtcNotesString(XtcEntry xtcEntry) {
    final buffer = StringBuffer();
    buffer.writeln('XTC-Eintrag:');
    buffer.writeln('Form: ${xtcEntry.form.displayName}');
    buffer.writeln('Bruchrillen: ${xtcEntry.bruchrillienAnzahl}');
    buffer.writeln('Inhalt: ${xtcEntry.content.displayName}');
    buffer.writeln('Größe: ${xtcEntry.size.displaySymbol}');
    if (xtcEntry.dosageMg != null) {
      buffer.writeln('Dosierung: ${xtcEntry.formattedDosage}');
    } else {
      buffer.writeln('Dosierung: Unbekannt');
    }
    buffer.writeln('Farbe: #${xtcEntry.color.value.toRadixString(16).padLeft(8, '0')}');
    if (xtcEntry.weightGrams != null) {
      buffer.writeln('Gewicht: ${xtcEntry.formattedWeight}');
    }
    if (xtcEntry.notes != null && xtcEntry.notes!.isNotEmpty) {
      buffer.writeln('Notizen: ${xtcEntry.notes}');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, isDark),
              Flexible(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_errorMessage != null) ...[
                          _buildErrorCard(context),
                          const SizedBox(height: 16),
                        ],
                        // Info text for quick entries
                        if (widget.isQuickEntry) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Erstelle einen Quick Button für diese XTC-Sorte',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        _buildSubstanceNameField(context),
                        const SizedBox(height: 24),
                        _buildFormSelector(context),
                        const SizedBox(height: 24),
                        _buildBruchrillienSelector(context),
                        const SizedBox(height: 24),
                        _buildContentSelector(context),
                        const SizedBox(height: 24),
                        XtcSizeSelector(
                          selectedSize: _selectedSize,
                          onSizeChanged: (size) => setState(() => _selectedSize = size),
                          color: _selectedColor,
                        ),
                        const SizedBox(height: 24),
                        _buildDosageSection(context),
                        const SizedBox(height: 24),
                        _buildColorSection(context),
                        const SizedBox(height: 24),
                        _buildWeightField(context),
                        const SizedBox(height: 24),
                        // Only show date/time picker for regular entries, not quick entries
                        if (!widget.isQuickEntry) ...[
                          _buildDateTimeSection(context),
                          const SizedBox(height: 24),
                        ],
                        _buildTimerSwitch(context),
                        const SizedBox(height: 24),
                        _buildNotesField(context),
                      ],
                    ),
                  ),
                ),
              ),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : DesignTokens.primaryGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.medication_rounded,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            widget.isQuickEntry ? 'XTC Quick Button' : 'XTC Eintrag',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubstanceNameField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Substanz Name',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _substanceNameController,
          decoration: const InputDecoration(
            hintText: 'z.B. "Pink Superman", "Blue Tesla"',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Bitte geben Sie einen Substanznamen ein';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFormSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Form',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<XtcForm>(
          value: _selectedForm,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: XtcForm.values.map((form) => DropdownMenuItem(
            value: form,
            child: Text(form.displayName),
          )).toList(),
          onChanged: (form) {
            if (form != null) {
              setState(() => _selectedForm = form);
            }
          },
        ),
      ],
    );
  }

  Widget _buildBruchrillienSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bruchrillen (Anzahl)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _bruchrillienAnzahl,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Anzahl der Bruchrillen',
          ),
          items: List.generate(5, (index) => DropdownMenuItem(
            value: index,
            child: Text(index == 0 ? 'Keine Bruchrillen' : '$index Bruchrille${index > 1 ? 'n' : ''}'),
          )),
          onChanged: (value) {
            if (value != null) {
              setState(() => _bruchrillienAnzahl = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildContentSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inhalt',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<XtcContent>(
          value: _selectedContent,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: XtcContent.values.map((content) => DropdownMenuItem(
            value: content,
            child: Text(content.displayName),
          )).toList(),
          onChanged: (content) {
            if (content != null) {
              setState(() => _selectedContent = content);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDosageSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Menge (mg)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text('Unbekannt'),
            Switch(
              value: _isDosageUnknown,
              onChanged: (value) {
                setState(() {
                  _isDosageUnknown = value;
                  if (value) {
                    _dosageController.clear();
                  }
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!_isDosageUnknown)
          TextFormField(
            controller: _dosageController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
            decoration: const InputDecoration(
              hintText: 'z.B. 120',
              suffixText: 'mg',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (!_isDosageUnknown && (value == null || value.trim().isEmpty)) {
                return 'Bitte geben Sie eine Dosierung ein oder wählen Sie "Unbekannt"';
              }
              if (!_isDosageUnknown && double.tryParse(value!.replaceAll(',', '.')) == null) {
                return 'Bitte geben Sie eine gültige Zahl ein';
              }
              return null;
            },
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Dosierung unbekannt',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildColorSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farbe',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        XtcColorPicker(
          initialColor: _selectedColor,
          onColorChanged: (color) => setState(() => _selectedColor = color),
        ),
      ],
    );
  }

  Widget _buildWeightField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gewicht (optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
          ],
          decoration: const InputDecoration(
            hintText: 'z.B. 0.3',
            suffixText: 'g',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty && double.tryParse(value.replaceAll(',', '.')) == null) {
              return 'Bitte geben Sie eine gültige Zahl ein';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datum & Uhrzeit',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDateTime,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 1)),
            );
            if (date != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
              );
              if (time != null) {
                setState(() {
                  _selectedDateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(_selectedDateTime),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerSwitch(BuildContext context) {
    return Row(
      children: [
        Text(
          'Timer starten (4h)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Switch(
          value: _startTimer,
          onChanged: (value) => setState(() => _startTimer = value),
        ),
      ],
    );
  }

  Widget _buildNotesField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notizen (optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Zusätzliche Notizen...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
                foregroundColor: _selectedColor.computeLuminance() > 0.5 
                    ? Colors.black 
                    : Colors.white,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Speichern'),
            ),
          ),
        ],
      ),
    );
  }
}