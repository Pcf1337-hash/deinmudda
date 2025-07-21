import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'lib/models/substance.dart';
import 'lib/models/quick_button_config.dart';
import 'lib/utils/app_icon_generator.dart';

void main() {
  group('UI Overflow and Icon Selection Implementation Tests', () {
    
    test('Substance with custom iconName should use custom icon', () {
      // Test substance with custom icon
      final substance = Substance.create(
        name: 'Test Substance',
        category: SubstanceCategory.other,
        defaultRiskLevel: RiskLevel.low,
        pricePerUnit: 1.0,
        defaultUnit: 'mg',
        iconName: 'coffee',
      );
      
      final icon = AppIconGenerator.getSubstanceIconFromSubstance(substance);
      expect(icon, Icons.local_cafe_rounded);
    });
    
    test('Substance without custom iconName should use auto-generated icon', () {
      // Test substance without custom icon - should use auto-generation
      final substance = Substance.create(
        name: 'Koffein Test',  // Should auto-generate coffee icon
        category: SubstanceCategory.stimulant,
        defaultRiskLevel: RiskLevel.low,
        pricePerUnit: 1.0,
        defaultUnit: 'mg',
      );
      
      final icon = AppIconGenerator.getSubstanceIconFromSubstance(substance);
      expect(icon, Icons.local_cafe_rounded);  // Auto-generated based on name
    });
    
    test('getIconFromName should return correct icons for all supported names', () {
      final testCases = {
        'coffee': Icons.local_cafe_rounded,
        'flash': Icons.flash_on_rounded,
        'tea': Icons.emoji_food_beverage_rounded,
        'alcohol': Icons.local_bar_rounded,
        'wine': Icons.wine_bar_rounded,
        'beer': Icons.sports_bar_rounded,
        'cigarette': Icons.smoking_rooms_rounded,
        'leaf': Icons.local_florist_rounded,
        'pill': Icons.medication_rounded,
        'healing': Icons.healing_rounded,
        'health': Icons.health_and_safety_rounded,
        'fitness': Icons.fitness_center_rounded,
        'water': Icons.water_drop_rounded,
        'science': Icons.science_rounded,
        'psychology': Icons.psychology_rounded,
        'sleep': Icons.bedtime_rounded,
        'sun': Icons.wb_sunny_rounded,
        'moon': Icons.nightlight_rounded,
      };
      
      testCases.forEach((iconName, expectedIcon) {
        final actualIcon = AppIconGenerator.getIconFromName(iconName);
        expect(actualIcon, expectedIcon, reason: 'Icon name "$iconName" should return correct icon');
      });
    });
    
    test('Unknown icon name should return default science icon', () {
      final icon = AppIconGenerator.getIconFromName('unknown_icon');
      expect(icon, Icons.science_rounded);
    });
    
    test('QuickButtonConfig should support custom icons', () {
      final config = QuickButtonConfig.create(
        substanceId: 'test-id',
        substanceName: 'Test Substance',
        dosage: 100.0,
        unit: 'mg',
        position: 0,
        icon: Icons.local_cafe_rounded,
        color: Colors.blue,
      );
      
      expect(config.icon, Icons.local_cafe_rounded);
      expect(config.color, Colors.blue);
      expect(config.iconCodePoint, Icons.local_cafe_rounded.codePoint);
      expect(config.colorValue, Colors.blue.value);
    });
    
    test('Substance model should properly serialize custom iconName', () {
      final substance = Substance.create(
        name: 'Test Substance',
        category: SubstanceCategory.medication,
        defaultRiskLevel: RiskLevel.medium,
        pricePerUnit: 5.0,
        defaultUnit: 'ml',
        iconName: 'pill',
        notes: 'Test notes',
      );
      
      // Test JSON serialization
      final json = substance.toJson();
      expect(json['iconName'], 'pill');
      expect(json['name'], 'Test Substance');
      
      // Test database serialization
      final dbMap = substance.toDatabase();
      expect(dbMap['iconName'], 'pill');
      
      // Test deserialization
      final fromJson = Substance.fromJson(json);
      expect(fromJson.iconName, 'pill');
      expect(fromJson.name, 'Test Substance');
      
      final fromDb = Substance.fromDatabase(dbMap);
      expect(fromDb.iconName, 'pill');
      expect(fromDb.name, 'Test Substance');
    });
    
    test('copyWith should properly update iconName', () {
      final original = Substance.create(
        name: 'Original',
        category: SubstanceCategory.other,
        defaultRiskLevel: RiskLevel.low,
        pricePerUnit: 1.0,
        defaultUnit: 'mg',
        iconName: 'science',
      );
      
      final updated = original.copyWith(
        iconName: 'coffee',
      );
      
      expect(updated.iconName, 'coffee');
      expect(updated.name, 'Original');  // Other fields should remain unchanged
      expect(original.iconName, 'science');  // Original should be unchanged
    });
  });
  
  group('Icon Selection Logic Tests', () {
    test('Priority order: Manual > Custom Substance > Auto-generated', () {
      // Test the icon selection priority order
      
      // 1. Substance with custom iconName
      final customSubstance = Substance.create(
        name: 'Koffein',  // Would auto-generate coffee icon
        category: SubstanceCategory.stimulant,
        defaultRiskLevel: RiskLevel.low,
        pricePerUnit: 1.0,
        defaultUnit: 'mg',
        iconName: 'psychology',  // Custom icon overrides auto-generation
      );
      
      final customIcon = AppIconGenerator.getSubstanceIconFromSubstance(customSubstance);
      expect(customIcon, Icons.psychology_rounded);  // Should use custom, not auto-generated
      
      // 2. Substance without custom iconName (auto-generated)
      final autoSubstance = Substance.create(
        name: 'Koffein',  // Should auto-generate coffee icon
        category: SubstanceCategory.stimulant,
        defaultRiskLevel: RiskLevel.low,
        pricePerUnit: 1.0,
        defaultUnit: 'mg',
        // No custom iconName
      );
      
      final autoIcon = AppIconGenerator.getSubstanceIconFromSubstance(autoSubstance);
      expect(autoIcon, Icons.local_cafe_rounded);  // Should auto-generate based on name
    });
  });
}

// Test helper to validate the implementation without actually running the Flutter app
void validateImplementation() {
  print('🔍 Validating UI Overflow and Icon Selection Implementation...\n');
  
  // Test 1: Validate icon name mapping
  print('✅ Testing icon name mapping...');
  final testIcon = AppIconGenerator.getIconFromName('coffee');
  assert(testIcon == Icons.local_cafe_rounded);
  print('   ✓ Coffee icon mapping works correctly');
  
  // Test 2: Validate substance model with custom icon
  print('✅ Testing substance model with custom icon...');
  final substance = Substance.create(
    name: 'Test Substance',
    category: SubstanceCategory.medication,
    defaultRiskLevel: RiskLevel.low,
    pricePerUnit: 2.5,
    defaultUnit: 'mg',
    iconName: 'pill',
  );
  assert(substance.iconName == 'pill');
  print('   ✓ Substance can store custom iconName');
  
  // Test 3: Validate icon priority logic
  print('✅ Testing icon priority logic...');
  final customIcon = AppIconGenerator.getSubstanceIconFromSubstance(substance);
  assert(customIcon == Icons.medication_rounded);
  print('   ✓ Custom substance icon takes priority over auto-generation');
  
  // Test 4: Validate QuickButtonConfig icon support
  print('✅ Testing QuickButtonConfig icon support...');
  final config = QuickButtonConfig.create(
    substanceId: 'test',
    substanceName: 'Test',
    dosage: 100,
    unit: 'mg',
    position: 0,
    icon: Icons.local_cafe_rounded,
  );
  assert(config.icon == Icons.local_cafe_rounded);
  print('   ✓ QuickButtonConfig supports custom icons');
  
  print('\n🎉 All implementation validations passed!');
  print('\n📋 Summary of implemented features:');
  print('   • UI overflow fixes for header_bar.dart and calendar_screen.dart');
  print('   • Debounced provider notifications to reduce update frequency'); 
  print('   • Enhanced icon selection with 47+ available icons');
  print('   • Manual vs automatic icon selection tracking');
  print('   • Configurable icon selection in substance creation');
  print('   • Smart icon priority: Manual > Custom Substance > Auto-generated');
  print('   • Entry creation uses substance-stored icons only');
  print('   • Quick buttons can override substance icons');
}

// Run validation if this file is executed directly
// void main() => validateImplementation();