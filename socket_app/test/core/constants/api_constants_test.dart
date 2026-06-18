import 'package:flutter_test/flutter_test.dart';
import 'package:socket_app/core/constants/api_constants.dart';

void main() {
  group('ApiConstants Security Tests', () {
    test('WebSocket URL should use secure protocol (wss://)', () {
      // Assert
      expect(
        ApiConstants.wsUrl.startsWith('wss://'),
        isTrue,
        reason:
            'WebSocket protocol must be secure to prevent data interception',
      );
    });

    test('Base URL should use secure protocol (https://)', () {
      // Assert
      expect(
        ApiConstants.baseUrl.startsWith('https://'),
        isTrue,
        reason: 'Base URL must be secure to prevent Man-in-the-Middle attacks',
      );
    });
  });
}
