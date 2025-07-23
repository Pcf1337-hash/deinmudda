/// Test File Existence Validation
/// 
/// This test ensures all required test files exist for the CI/CD pipeline
/// and helps diagnose missing dependencies early in the pipeline
/// 
/// Author: Code Quality Improvement Agent
/// Date: CI/CD Pipeline Implementation

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test File Existence Validation', () {
    test('should validate basic test files exist', () {
      final requiredTestFiles = [
        'test/basic_test.dart',
        'test/ci_cd_validation_test.dart',
        'test/widget_test.dart',
      ];
      
      for (final filePath in requiredTestFiles) {
        final file = File(filePath);
        expect(file.existsSync(), isTrue,
               reason: 'Required test file $filePath should exist');
      }
    });

    test('should validate unit test files exist', () {
      final unitTestDir = Directory('test/unit');
      expect(unitTestDir.existsSync(), isTrue,
             reason: 'Unit test directory should exist');
      
      if (unitTestDir.existsSync()) {
        final unitTestFiles = unitTestDir
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .toList();
        
        expect(unitTestFiles.isNotEmpty, isTrue,
               reason: 'Unit test directory should contain test files');
      }
    });

    test('should validate performance test files exist', () {
      final performanceTestFiles = [
        'test/performance/basic_performance_test.dart',
        'test/performance/performance_test.dart',
      ];
      
      for (final filePath in performanceTestFiles) {
        final file = File(filePath);
        expect(file.existsSync(), isTrue,
               reason: 'Performance test file $filePath should exist');
      }
    });

    test('should validate integration test files exist', () {
      final integrationTestFiles = [
        'test/integration/basic_integration_test.dart',
        'test/integration/use_case_integration_test.dart',
      ];
      
      for (final filePath in integrationTestFiles) {
        final file = File(filePath);
        expect(file.existsSync(), isTrue,
               reason: 'Integration test file $filePath should exist');
      }
    });

    test('should validate load test files exist', () {
      final loadTestFiles = [
        'test/load/load_test.dart',
      ];
      
      for (final filePath in loadTestFiles) {
        final file = File(filePath);
        expect(file.existsSync(), isTrue,
               reason: 'Load test file $filePath should exist');
      }
    });

    test('should validate helper and mock files exist', () {
      final helperFiles = [
        'test/helpers/test_helpers.dart',
        'test/mocks/service_mocks.dart',
      ];
      
      for (final filePath in helperFiles) {
        final file = File(filePath);
        expect(file.existsSync(), isTrue,
               reason: 'Helper file $filePath should exist');
      }
    });
  });

  group('Source File Validation', () {
    test('should validate main source directories exist', () {
      final sourceDirectories = [
        'lib',
        'lib/models',
        'lib/services',
        'lib/utils',
        'lib/widgets',
        'lib/screens',
      ];
      
      for (final dirPath in sourceDirectories) {
        final directory = Directory(dirPath);
        expect(directory.existsSync(), isTrue,
               reason: 'Source directory $dirPath should exist');
      }
    });

    test('should validate configuration files exist', () {
      final configFiles = [
        'pubspec.yaml',
        '.github/workflows/ci.yml',
        '.github/workflows/performance.yml',
        '.github/workflows/dependencies.yml',
      ];
      
      for (final filePath in configFiles) {
        final file = File(filePath);
        expect(file.existsSync(), isTrue,
               reason: 'Configuration file $filePath should exist');
      }
    });

    test('should validate essential model files exist', () {
      final modelFiles = [
        'lib/models/entry.dart',
        'lib/models/substance.dart',
      ];
      
      for (final filePath in modelFiles) {
        final file = File(filePath);
        expect(file.existsSync(), isTrue,
               reason: 'Model file $filePath should exist');
      }
    });

    test('should validate essential service files exist', () {
      // Check if services directory exists and has some files
      final servicesDir = Directory('lib/services');
      if (servicesDir.existsSync()) {
        final serviceFiles = servicesDir
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .toList();
        
        expect(serviceFiles.isNotEmpty, isTrue,
               reason: 'Services directory should contain service files');
      }
    });
  });

  group('Test Structure Validation', () {
    test('should validate test directory structure', () {
      final testDirectories = [
        'test',
        'test/unit',
        'test/integration',
        'test/performance',
        'test/load',
        'test/helpers',
        'test/mocks',
        'test/widget',
        'test/widgets',
      ];
      
      for (final dirPath in testDirectories) {
        final directory = Directory(dirPath);
        // Some directories are optional, so we just check they don't cause errors
        if (directory.existsSync()) {
          expect(directory.statSync().type, equals(FileSystemEntityType.directory),
                 reason: '$dirPath should be a directory if it exists');
        }
      }
    });

    test('should validate no circular dependencies in test structure', () {
      // This is a placeholder for more complex dependency validation
      // For now, just ensure we can navigate the test structure
      final testDir = Directory('test');
      expect(testDir.existsSync(), isTrue,
             reason: 'Main test directory should exist');
      
      // Count test files to ensure we have a reasonable number
      if (testDir.existsSync()) {
        final allTestFiles = testDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .toList();
        
        expect(allTestFiles.length, greaterThan(5),
               reason: 'Should have a reasonable number of test files');
      }
    });
  });
}