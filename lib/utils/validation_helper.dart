import '../utils/unit_manager.dart';

class ValidationHelper {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Password validation
  static bool isValidPassword(String password) {
    // At least 8 characters, one uppercase, one lowercase, one number
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  // Phone number validation (German format)
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(
      r'^(\+49|0)[1-9]\d{8,11}$',
    );
    return phoneRegex.hasMatch(phone.replaceAll(' ', '').replaceAll('-', ''));
  }

  // Substance name validation
  static bool isValidSubstanceName(String name) {
    if (name.trim().isEmpty) return false;
    if (name.trim().length < 2) return false;
    if (name.trim().length > 50) return false;
    
    // Only allow letters, numbers, spaces, and common symbols
    final nameRegex = RegExp(r'^[a-zA-ZäöüÄÖÜß0-9\s\-_()]+$');
    return nameRegex.hasMatch(name.trim());
  }

  // Dosage validation
  static bool isValidDosage(String dosage) {
    if (dosage.trim().isEmpty) return false;
    
    final cleanDosage = dosage.replaceAll(',', '.');
    final dosageValue = double.tryParse(cleanDosage);
    
    if (dosageValue == null) return false;
    if (dosageValue <= 0) return false;
    if (dosageValue > 999999) return false; // Reasonable upper limit
    
    return true;
  }

  // Unit validation
  static bool isValidUnit(String unit) {
    if (unit.trim().isEmpty) return false;
    if (unit.trim().length > 20) return false;
    
    // Use UnitManager for more comprehensive validation
    return UnitManager.isValidUnit(unit.trim());
  }

  // Cost validation
  static bool isValidCost(String cost) {
    if (cost.trim().isEmpty) return true; // Cost is optional
    
    final cleanCost = cost.replaceAll(',', '.');
    final costValue = double.tryParse(cleanCost);
    
    if (costValue == null) return false;
    if (costValue < 0) return false;
    if (costValue > 999999) return false; // Reasonable upper limit
    
    return true;
  }

  // Notes validation
  static bool isValidNotes(String notes) {
    if (notes.trim().isEmpty) return true; // Notes are optional
    if (notes.trim().length > 1000) return false; // Reasonable limit
    
    return true;
  }

  // Weight validation (for dosage calculator)
  static bool isValidWeight(String weight) {
    if (weight.trim().isEmpty) return false;
    
    final cleanWeight = weight.replaceAll(',', '.');
    final weightValue = double.tryParse(cleanWeight);
    
    if (weightValue == null) return false;
    if (weightValue <= 0) return false;
    if (weightValue < 20 || weightValue > 300) return false; // Reasonable range in kg
    
    return true;
  }

  // Height validation (for dosage calculator)
  static bool isValidHeight(String height) {
    if (height.trim().isEmpty) return false;
    
    final cleanHeight = height.replaceAll(',', '.');
    final heightValue = double.tryParse(cleanHeight);
    
    if (heightValue == null) return false;
    if (heightValue <= 0) return false;
    if (heightValue < 100 || heightValue > 250) return false; // Reasonable range in cm
    
    return true;
  }

  // Age validation (for dosage calculator)
  static bool isValidAge(String age) {
    if (age.trim().isEmpty) return false;
    
    final ageValue = int.tryParse(age);
    
    if (ageValue == null) return false;
    if (ageValue < 18 || ageValue > 120) return false; // Legal age and reasonable upper limit
    
    return true;
  }

  // Date validation
  static bool isValidDate(DateTime? date) {
    if (date == null) return false;
    
    final now = DateTime.now();
    final earliestDate = DateTime(2000); // Reasonable earliest date
    final latestDate = now.add(const Duration(days: 1)); // Allow entries for today and tomorrow
    
    return date.isAfter(earliestDate) && date.isBefore(latestDate);
  }

  // Time validation
  static bool isValidTime(DateTime? time) {
    if (time == null) return false;
    
    // Time is always valid if date is valid
    return true;
  }

  // Generic number validation
  static bool isValidNumber(String value, {double? min, double? max}) {
    if (value.trim().isEmpty) return false;
    
    final cleanValue = value.replaceAll(',', '.');
    final numberValue = double.tryParse(cleanValue);
    
    if (numberValue == null) return false;
    
    if (min != null && numberValue < min) return false;
    if (max != null && numberValue > max) return false;
    
    return true;
  }

  // Generic text validation
  static bool isValidText(String text, {int? minLength, int? maxLength}) {
    if (minLength != null && text.trim().length < minLength) return false;
    if (maxLength != null && text.trim().length > maxLength) return false;
    
    return true;
  }

  // Sanitize input text
  static String sanitizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Format number for display
  static String formatNumber(double number, {int decimals = 2}) {
    return number.toStringAsFixed(decimals).replaceAll('.', ',');
  }

  // Parse number from German format
  static double? parseNumber(String value) {
    final cleanValue = value.replaceAll(',', '.');
    return double.tryParse(cleanValue);
  }

  // Validate and format dosage input
  static String? validateAndFormatDosage(String input) {
    if (!isValidDosage(input)) return null;
    
    final value = parseNumber(input);
    if (value == null) return null;
    
    return formatNumber(value);
  }

  // Validate and format cost input
  static String? validateAndFormatCost(String input) {
    if (input.trim().isEmpty) return '0,00';
    if (!isValidCost(input)) return null;
    
    final value = parseNumber(input);
    if (value == null) return null;
    
    return formatNumber(value);
  }

  // Get validation error message
  static String? getValidationError(String field, String value) {
    switch (field.toLowerCase()) {
      case 'substance':
      case 'substanz':
        if (!isValidSubstanceName(value)) {
          return 'Substanzname muss zwischen 2 und 50 Zeichen lang sein';
        }
        break;
      case 'dosage':
      case 'dosierung':
        if (!isValidDosage(value)) {
          return 'Bitte geben Sie eine gültige Dosierung ein';
        }
        break;
      case 'unit':
      case 'einheit':
        if (!isValidUnit(value)) {
          return 'Ungültige Einheit. Erlaubte Einheiten: ${UnitManager.validUnits.join(', ')}';
        }
        break;
      case 'cost':
      case 'kosten':
        if (!isValidCost(value)) {
          return 'Bitte geben Sie gültige Kosten ein';
        }
        break;
      case 'notes':
      case 'notizen':
        if (!isValidNotes(value)) {
          return 'Notizen dürfen maximal 1000 Zeichen lang sein';
        }
        break;
      case 'weight':
      case 'gewicht':
        if (!isValidWeight(value)) {
          return 'Gewicht muss zwischen 20 und 300 kg liegen';
        }
        break;
      case 'height':
      case 'größe':
        if (!isValidHeight(value)) {
          return 'Größe muss zwischen 100 und 250 cm liegen';
        }
        break;
      case 'age':
      case 'alter':
        if (!isValidAge(value)) {
          return 'Alter muss zwischen 18 und 120 Jahren liegen';
        }
        break;
      case 'email':
        if (!isValidEmail(value)) {
          return 'Bitte geben Sie eine gültige E-Mail-Adresse ein';
        }
        break;
      case 'password':
      case 'passwort':
        if (!isValidPassword(value)) {
          return 'Passwort muss mindestens 8 Zeichen, einen Groß- und Kleinbuchstaben sowie eine Zahl enthalten';
        }
        break;
      case 'phone':
      case 'telefon':
        if (!isValidPhoneNumber(value)) {
          return 'Bitte geben Sie eine gültige Telefonnummer ein';
        }
        break;
    }
    return null;
  }
}
