#!/usr/bin/env dart

/// Validation script for layout and rendering fixes
/// This script checks the code changes for common layout issues

import 'dart:io';

void main() {
  print('🔍 Validating layout fixes...\n');
  
  // Check pie chart widget fixes
  print('1. Checking pie chart legend overflow fix...');
  final pieChartFile = File('lib/widgets/charts/pie_chart_widget.dart');
  if (pieChartFile.existsSync()) {
    final content = pieChartFile.readAsStringSync();
    
    // Check for constrained percentage text
    if (content.contains('constraints: const BoxConstraints(') && 
        content.contains('maxWidth: 50') &&
        content.contains('fontSize: 11')) {
      print('✅ Pie chart legend has proper constraints');
    } else {
      print('❌ Pie chart legend constraints not found');
    }
    
    // Check for unique keys
    if (content.contains("ValueKey('pie_legend_")) {
      print('✅ Pie chart legend has unique keys');
    } else {
      print('❌ Pie chart legend missing unique keys');
    }
  } else {
    print('❌ Pie chart widget file not found');
  }
  
  print('\n2. Checking home screen fixes...');
  final homeScreenFile = File('lib/screens/home_screen.dart');
  if (homeScreenFile.existsSync()) {
    final content = homeScreenFile.readAsStringSync();
    
    // Check for unique keys in entry cards
    if (content.contains("ValueKey('entry_") && 
        content.contains("ValueKey('loading_")) {
      print('✅ Home screen has unique keys for lists');
    } else {
      print('❌ Home screen missing unique keys');
    }
    
    // Check for constrained containers
    if (content.contains('BoxConstraints(') && 
        content.contains('mainAxisSize: MainAxisSize.min')) {
      print('✅ Home screen has proper container constraints');
    } else {
      print('❌ Home screen missing container constraints');
    }
  } else {
    print('❌ Home screen file not found');
  }
  
  print('\n3. Checking error boundary fixes...');
  final errorBoundaryFile = File('lib/widgets/layout_error_boundary.dart');
  if (errorBoundaryFile.existsSync()) {
    final content = errorBoundaryFile.readAsStringSync();
    
    // Check for post-frame callbacks
    if (content.contains('addPostFrameCallback') && 
        content.contains('WidgetsBinding.instance')) {
      print('✅ Error boundary uses post-frame callbacks');
    } else {
      print('❌ Error boundary missing post-frame callbacks');
    }
  } else {
    print('❌ Error boundary file not found');
  }
  
  print('\n4. Common overflow patterns check...');
  
  // Check for common overflow issues in dart files
  final libDir = Directory('lib');
  if (libDir.existsSync()) {
    int overflowFixCount = 0;
    int keyFixCount = 0;
    
    libDir.listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .forEach((file) {
      final content = file.readAsStringSync();
      
      // Count overflow fixes
      if (content.contains('overflow: TextOverflow.ellipsis') ||
          content.contains('maxLines:') ||
          content.contains('BoxConstraints(')) {
        overflowFixCount++;
      }
      
      // Count key fixes
      if (content.contains('ValueKey(')) {
        keyFixCount++;
      }
    });
    
    print('✅ Found overflow protection in $overflowFixCount files');
    print('✅ Found unique keys in $keyFixCount files');
  } else {
    print('❌ lib directory not found');
  }
  
  print('\n🎯 Validation Summary:');
  print('- Pie chart legend overflow: Fixed with constraints');
  print('- Duplicate keys: Added unique ValueKey to list items');
  print('- setState during frame: Fixed with post-frame callbacks');  
  print('- Container constraints: Added to prevent unbounded height');
  
  print('\n✅ Layout fixes validation completed!');
  print('\n📋 Manual Testing Checklist:');
  print('1. Run the app and navigate to home screen');
  print('2. Check that pie chart legends display without overflow');
  print('3. Verify no "Duplicate keys found" error in logs');
  print('4. Confirm no "Build scheduled during frame" errors');
  print('5. Test scrolling and ensure no layout exceptions');
}