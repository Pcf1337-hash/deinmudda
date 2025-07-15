#!/usr/bin/env dart

/// UI Validation Tool
/// Analyzes Dart files for potential UI issues and inconsistencies

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🧪 Starting UI Validation Analysis...\n');
  
  final validator = UIValidator();
  await validator.validateProject();
}

class UIValidator {
  final List<String> _issues = [];
  final List<String> _warnings = [];
  final List<String> _suggestions = [];

  Future<void> validateProject() async {
    await _validateScreens();
    await _validateWidgets();
    await _validateThemes();
    await _validateAnimations();
    await _validateConsistency();
    
    _printResults();
  }

  Future<void> _validateScreens() async {
    print('🏠 Validating Screens...');
    
    final screenFiles = await _findFiles('lib/screens', '.dart');
    
    for (final file in screenFiles) {
      await _validateScreen(file);
    }
  }

  Future<void> _validateScreen(File file) async {
    final content = await file.readAsString();
    final filename = file.path.split('/').last;
    
    // Check for overflow prevention
    if (!content.contains('SingleChildScrollView') && 
        !content.contains('ListView') && 
        !content.contains('CustomScrollView') &&
        content.contains('Column(') &&
        content.length > 5000) {
      _warnings.add('$filename: Large screen without scrolling - potential overflow risk');
    }
    
    // Check for responsive design
    if (!content.contains('LayoutBuilder') && 
        !content.contains('MediaQuery') &&
        !content.contains('Flexible') &&
        !content.contains('Expanded') &&
        content.contains('Container(') &&
        content.length > 3000) {
      _warnings.add('$filename: No responsive design patterns detected');
    }
    
    // Check for accessibility
    if (!content.contains('Semantics') && 
        !content.contains('semanticsLabel') &&
        content.contains('GestureDetector') &&
        content.length > 2000) {
      _suggestions.add('$filename: Consider adding accessibility labels');
    }
    
    // Check for proper text overflow handling
    if (content.contains('Text(') && 
        !content.contains('overflow:') &&
        !content.contains('maxLines:') &&
        content.length > 2000) {
      _warnings.add('$filename: Text widgets without overflow handling');
    }
    
    // Check for HeaderBar usage
    if (content.contains('AppBar(') && !content.contains('HeaderBar(')) {
      _issues.add('$filename: Using AppBar instead of consistent HeaderBar');
    }
    
    // Check for ConsistentFAB usage
    if (content.contains('FloatingActionButton(') && 
        !content.contains('ConsistentFAB(') &&
        !content.contains('TrippyFAB(')) {
      _issues.add('$filename: Using FloatingActionButton instead of ConsistentFAB');
    }
  }

  Future<void> _validateWidgets() async {
    print('🎨 Validating Widgets...');
    
    final widgetFiles = await _findFiles('lib/widgets', '.dart');
    
    for (final file in widgetFiles) {
      await _validateWidget(file);
    }
  }

  Future<void> _validateWidget(File file) async {
    final content = await file.readAsString();
    final filename = file.path.split('/').last;
    
    // Check for animation disposal
    if (content.contains('AnimationController') && 
        !content.contains('dispose()')) {
      _issues.add('$filename: AnimationController without proper disposal');
    }
    
    // Check for proper state management
    if (content.contains('setState(') && 
        !content.contains('mounted') &&
        content.contains('async')) {
      _warnings.add('$filename: Async setState without mounted check');
    }
    
    // Check for hardcoded colors
    if (content.contains('Color(0x') && 
        !content.contains('DesignTokens.')) {
      _warnings.add('$filename: Hardcoded colors instead of design tokens');
    }
    
    // Check for hardcoded animations
    if (content.contains('Duration(') && 
        !content.contains('DesignTokens.') &&
        !content.contains('const Duration')) {
      _suggestions.add('$filename: Consider using design token animations');
    }
  }

  Future<void> _validateThemes() async {
    print('🌈 Validating Themes...');
    
    final themeFiles = await _findFiles('lib/theme', '.dart');
    
    for (final file in themeFiles) {
      await _validateTheme(file);
    }
  }

  Future<void> _validateTheme(File file) async {
    final content = await file.readAsString();
    final filename = file.path.split('/').last;
    
    // Check for accessibility compliance
    if (content.contains('Color(') && 
        !content.contains('// Contrast ratio') &&
        filename.contains('theme')) {
      _suggestions.add('$filename: Consider adding contrast ratio comments');
    }
    
    // Check for trippy mode support
    if (content.contains('ThemeData') && 
        !content.contains('psychedelic') &&
        !content.contains('trippy')) {
      _suggestions.add('$filename: Consider adding trippy mode support');
    }
  }

  Future<void> _validateAnimations() async {
    print('⚡ Validating Animations...');
    
    final allFiles = await _findFiles('lib', '.dart');
    
    for (final file in allFiles) {
      await _validateAnimation(file);
    }
  }

  Future<void> _validateAnimation(File file) async {
    final content = await file.readAsString();
    final filename = file.path.split('/').last;
    
    // Check for performance-heavy animations
    if (content.contains('AnimationController') && 
        content.contains('Duration(milliseconds:') &&
        !content.contains('vsync:')) {
      _issues.add('$filename: Animation without vsync - performance issue');
    }
    
    // Check for proper curve usage
    if (content.contains('Animation') && 
        !content.contains('Curves.') &&
        !content.contains('DesignTokens.curve')) {
      _suggestions.add('$filename: Consider using predefined curves');
    }
  }

  Future<void> _validateConsistency() async {
    print('🔄 Validating Consistency...');
    
    final allFiles = await _findFiles('lib', '.dart');
    final designTokensUsage = <String>[];
    
    for (final file in allFiles) {
      final content = await file.readAsString();
      final filename = file.path.split('/').last;
      
      // Check for design tokens import
      if (content.contains('DesignTokens.')) {
        designTokensUsage.add(filename);
      }
      
      // Check for lightning icon usage
      if (content.contains('Icons.flash') || 
          content.contains('Icons.bolt') ||
          content.contains('Icons.electric')) {
        if (!content.contains('DesignTokens.lightningIcon')) {
          _issues.add('$filename: Using custom lightning icon instead of DesignTokens.lightningIcon');
        }
      }
      
      // Check for spacing consistency
      if (content.contains('EdgeInsets.') && 
          !content.contains('Spacing.') &&
          !content.contains('DesignTokens.')) {
        _warnings.add('$filename: Hardcoded spacing instead of design tokens');
      }
    }
    
    print('📊 Design tokens used in ${designTokensUsage.length} files');
  }

  Future<List<File>> _findFiles(String directory, String extension) async {
    final dir = Directory(directory);
    if (!await dir.exists()) return [];
    
    final files = <File>[];
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith(extension)) {
        files.add(entity);
      }
    }
    
    return files;
  }

  void _printResults() {
    print('\n' + '=' * 50);
    print('🎯 UI Validation Results');
    print('=' * 50);
    
    if (_issues.isNotEmpty) {
      print('\n❌ ISSUES FOUND (${_issues.length}):');
      for (final issue in _issues) {
        print('  • $issue');
      }
    }
    
    if (_warnings.isNotEmpty) {
      print('\n⚠️  WARNINGS (${_warnings.length}):');
      for (final warning in _warnings) {
        print('  • $warning');
      }
    }
    
    if (_suggestions.isNotEmpty) {
      print('\n💡 SUGGESTIONS (${_suggestions.length}):');
      for (final suggestion in _suggestions) {
        print('  • $suggestion');
      }
    }
    
    if (_issues.isEmpty && _warnings.isEmpty && _suggestions.isEmpty) {
      print('\n✅ No issues found! UI validation passed.');
    }
    
    print('\n📋 SUMMARY:');
    print('  Issues: ${_issues.length}');
    print('  Warnings: ${_warnings.length}');
    print('  Suggestions: ${_suggestions.length}');
    
    // Generate recommendations
    print('\n🔧 RECOMMENDATIONS:');
    
    if (_issues.isNotEmpty) {
      print('  1. Fix critical issues first (inconsistent component usage)');
    }
    
    if (_warnings.isNotEmpty) {
      print('  2. Address warnings to improve robustness');
    }
    
    if (_suggestions.isNotEmpty) {
      print('  3. Consider suggestions for better maintainability');
    }
    
    print('  4. Run manual testing with UI_MANUAL_TESTING_GUIDE.md');
    print('  5. Execute ui_validation_test.dart for automated testing');
    
    print('\n✨ UI validation complete!');
  }
}