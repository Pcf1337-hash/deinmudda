/// Simple validation of our database model changes
import 'lib/models/quick_button_config.dart';
import 'lib/models/entry.dart';
import 'lib/services/database_service.dart';

void main() {
  print('🔍 Validating model imports and basic functionality...');
  
  try {
    // Test QuickButtonConfig with icon and color
    final quickButton = QuickButtonConfig.create(
      substanceId: 'test',
      substanceName: 'Test',
      dosage: 100.0,
      unit: 'mg',
      icon: null, // Test with null icon
      color: null, // Test with null color
      position: 0,
    );
    
    print('✅ QuickButtonConfig creation works');
    print('   - toDatabase(): ${quickButton.toDatabase().keys}');
    
    // Test Entry with icon and color
    final entry = Entry.create(
      substanceId: 'test',
      substanceName: 'Test',
      dosage: 50.0,
      unit: 'mg',
      dateTime: DateTime.now(),
      icon: null,
      color: null,
    );
    
    print('✅ Entry creation works');
    print('   - toDatabase(): ${entry.toDatabase().keys}');
    
    // Test DatabaseService instantiation
    final dbService = DatabaseService();
    print('✅ DatabaseService instantiation works');
    
    print('\n🎉 All basic validations passed!');
    
  } catch (e, stackTrace) {
    print('❌ Validation failed: $e');
    print('Stack trace: $stackTrace');
  }
}