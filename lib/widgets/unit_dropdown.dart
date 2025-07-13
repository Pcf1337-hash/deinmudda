import 'package:flutter/material.dart';
import '../utils/unit_manager.dart';
import '../models/substance.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';

class UnitDropdown extends StatefulWidget {
  final TextEditingController controller;
  final List<Substance> substances;
  final SubstanceCategory? selectedCategory;
  final String? Function(String?)? validator;

  const UnitDropdown({
    super.key,
    required this.controller,
    required this.substances,
    this.selectedCategory,
    this.validator,
  });

  @override
  State<UnitDropdown> createState() => _UnitDropdownState();
}

class _UnitDropdownState extends State<UnitDropdown> {
  List<String> _suggestedUnits = [];
  List<String> _filteredUnits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnits();
    widget.controller.addListener(_filterUnits);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_filterUnits);
    super.dispose();
  }

  Future<void> _loadUnits() async {
    try {
      final suggested = await UnitManager.getSuggestedUnits(widget.substances);
      
      // Add category-specific units if a category is selected
      if (widget.selectedCategory != null) {
        final categoryUnits = UnitManager.getRecommendedUnitsForCategory(
          widget.selectedCategory!
        );
        suggested.insertAll(0, categoryUnits);
      }
      
      // Remove duplicates and sort
      final uniqueUnits = suggested.toSet().toList();
      uniqueUnits.sort();
      
      setState(() {
        _suggestedUnits = uniqueUnits;
        _filteredUnits = uniqueUnits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _suggestedUnits = UnitManager.validUnits;
        _filteredUnits = UnitManager.validUnits;
        _isLoading = false;
      });
    }
  }

  void _filterUnits() {
    final query = widget.controller.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUnits = _suggestedUnits;
      } else {
        _filteredUnits = _suggestedUnits
            .where((unit) => unit.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _selectUnit(String unit) {
    widget.controller.text = unit;
    setState(() {
      _filteredUnits = _suggestedUnits;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: TextFormField(
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: 'Einheit',
              border: InputBorder.none,
              suffixIcon: Icon(
                Icons.expand_more_rounded,
                color: isDark ? Colors.white70 : Colors.grey,
              ),
              hintText: 'z.B. mg, g, ml, Tablette',
            ),
            validator: widget.validator,
            onTap: () => _showUnitBottomSheet(context),
            readOnly: false,
          ),
        ),
        if (widget.controller.text.isNotEmpty && _filteredUnits.isNotEmpty)
          _buildQuickSuggestions(context, isDark),
      ],
    );
  }

  Widget _buildQuickSuggestions(BuildContext context, bool isDark) {
    final displayUnits = _filteredUnits.take(3).toList();
    
    if (displayUnits.isEmpty || 
        (displayUnits.length == 1 && displayUnits.first == widget.controller.text)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: displayUnits.map((unit) {
          final isSelected = unit == widget.controller.text;
          
          return GestureDetector(
            onTap: () => _selectUnit(unit),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? DesignTokens.accentCyan.withOpacity(0.2)
                    : (isDark ? Colors.white10 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(color: DesignTokens.accentCyan, width: 1)
                    : null,
              ),
              child: Text(
                unit,
                style: TextStyle(
                  color: isSelected 
                      ? DesignTokens.accentCyan
                      : (isDark ? Colors.white70 : Colors.grey.shade700),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showUnitBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Einheit auswählen',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Unit categories
            Expanded(
              child: _buildUnitCategories(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitCategories(BuildContext context, bool isDark) {
    final categories = {
      'Häufig verwendet': _getFrequentlyUsedUnits(),
      'Masse': ['mg', 'g', 'kg'],
      'Volumen': ['ml', 'l'],
      'Anzahl': ['Stück', 'Tablette', 'Kapsel', 'Tropfen'],
      'Internationale Einheiten': ['IE', 'IU'],
      'Benutzerdefiniert': ['Flasche', 'Bong', 'Joint', 'Zug', 'Portion'],
    };

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories.keys.elementAt(index);
        final units = categories[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.accentCyan,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: units.map((unit) {
                final isSelected = unit == widget.controller.text;
                
                return GestureDetector(
                  onTap: () {
                    _selectUnit(unit);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DesignTokens.accentCyan.withOpacity(0.2)
                          : (isDark ? Colors.white10 : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: DesignTokens.accentCyan, width: 1)
                          : null,
                    ),
                    child: Text(
                      unit,
                      style: TextStyle(
                        color: isSelected 
                            ? DesignTokens.accentCyan
                            : (isDark ? Colors.white : Colors.black),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  List<String> _getFrequentlyUsedUnits() {
    final frequentUnits = <String>[];
    
    // Add units from substances
    for (final substance in widget.substances) {
      if (substance.defaultUnit.isNotEmpty) {
        frequentUnits.add(substance.defaultUnit);
      }
    }
    
    // Add common units
    frequentUnits.addAll(['mg', 'g', 'ml', 'Tablette', 'Stück']);
    
    // Remove duplicates and sort by frequency
    final unitCounts = <String, int>{};
    for (final unit in frequentUnits) {
      unitCounts[unit] = (unitCounts[unit] ?? 0) + 1;
    }
    
    final sorted = unitCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(6).map((e) => e.key).toList();
  }
}