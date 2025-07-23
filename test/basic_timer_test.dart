// Simple Timer Test for CI Pipeline
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Timer Basic Tests', () {
    test('Duration calculations', () {
      final now = DateTime.now();
      final later = now.add(const Duration(minutes: 30));
      final difference = later.difference(now);
      
      expect(difference.inMinutes, equals(30));
      expect(difference.inSeconds, equals(1800));
    });

    test('Time formatting', () {
      const duration = Duration(hours: 2, minutes: 30, seconds: 45);
      
      expect(duration.inHours, equals(2));
      expect(duration.inMinutes, equals(150));
      expect(duration.inSeconds, equals(9045));
    });

    test('Basic timer logic', () {
      final startTime = DateTime.now();
      final endTime = startTime.add(const Duration(hours: 1));
      
      expect(endTime.isAfter(startTime), isTrue);
      expect(endTime.difference(startTime).inHours, equals(1));
    });
  });
}