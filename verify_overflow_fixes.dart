#!/usr/bin/env dart

import 'dart:io';

void main() {
  print('🔍 Verifying overflow fixes in substance dosage cards...\n');
  
  // Check if key files exist
  final filesToCheck = [
    'lib/widgets/dosage_calculator/substance_card.dart',
    'lib/widgets/dosage_calculator/dosage_result_card.dart',
    'lib/screens/dosage_calculator/dosage_calculator_screen.dart',
  ];
  
  for (final file in filesToCheck) {
    final fileExists = File(file).existsSync();
    print('${fileExists ? '✅' : '❌'} $file');
  }
  
  print('\n📋 Checking key overflow fixes...');
  
  // Check substance_card.dart fixes
  final substanceCardContent = File('lib/widgets/dosage_calculator/substance_card.dart').readAsStringSync();
  
  final fixes = {
    'Fixed height removed': !substanceCardContent.contains('height: 240'),
    'Scrolling enabled': substanceCardContent.contains('ClampingScrollPhysics'),
    'Flexible widgets added': substanceCardContent.contains('Flexible('),
    'Constraints added': substanceCardContent.contains('BoxConstraints('),
    'Overflow ellipsis': substanceCardContent.contains('TextOverflow.ellipsis'),
    'FittedBox usage': substanceCardContent.contains('FittedBox('),
  };
  
  fixes.forEach((description, isFixed) {
    print('${isFixed ? '✅' : '❌'} $description');
  });
  
  // Check dosage_result_card.dart fixes
  final dosageResultContent = File('lib/widgets/dosage_calculator/dosage_result_card.dart').readAsStringSync();
  
  final resultCardFixes = {
    'LayoutBuilder for responsive design': dosageResultContent.contains('LayoutBuilder('),
    'FittedBox for text scaling': dosageResultContent.contains('FittedBox('),
    'Responsive item width': dosageResultContent.contains('itemWidth.clamp('),
  };
  
  resultCardFixes.forEach((description, isFixed) {
    print('${isFixed ? '✅' : '❌'} $description');
  });
  
  // Check dosage_calculator_screen.dart fixes
  final calculatorScreenContent = File('lib/screens/dosage_calculator/dosage_calculator_screen.dart').readAsStringSync();
  
  final screenFixes = {
    'Popular substances responsive layout': calculatorScreenContent.contains('LayoutBuilder('),
    'Card width constraints': calculatorScreenContent.contains('itemWidth.clamp('),
    'Flexible text in cards': calculatorScreenContent.contains('Flexible('),
  };
  
  screenFixes.forEach((description, isFixed) {
    print('${isFixed ? '✅' : '❌'} $description');
  });
  
  print('\n🎯 Summary:');
  final totalFixes = fixes.length + resultCardFixes.length + screenFixes.length;
  final appliedFixes = fixes.values.where((f) => f).length + 
                     resultCardFixes.values.where((f) => f).length + 
                     screenFixes.values.where((f) => f).length;
  
  print('Applied fixes: $appliedFixes/$totalFixes');
  
  if (appliedFixes == totalFixes) {
    print('🎉 All overflow fixes have been successfully applied!');
  } else {
    print('⚠️  Some fixes may be missing. Please review the implementation.');
  }
  
  print('\n💡 Key improvements:');
  print('• Removed fixed height constraints (240px) that caused overflow');
  print('• Enabled proper scrolling with ClampingScrollPhysics');
  print('• Added responsive design with LayoutBuilder and constraints');
  print('• Implemented flexible text handling with FittedBox');
  print('• Added proper overflow handling with ellipsis');
  print('• Improved calculation button layout');
}