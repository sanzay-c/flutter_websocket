import 'package:flutter_test/flutter_test.dart';

void main() {
  // This is a simple group of tests to get you started!
  group('Starter Tests', () {
    test('A simple math test to prove the testing robot works', () {
      // Arrange
      int a = 2;
      int b = 2;

      // Act
      int sum = a + b;

      // Assert
      expect(sum, 4);
    });

    test('String manipulation test', () {
      // Arrange
      String text = "hello bajar";

      // Act
      String upperCaseText = text.toUpperCase();

      // Assert
      expect(upperCaseText, "HELLO BAJAR");
    });
  });
}
