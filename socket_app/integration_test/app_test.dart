import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:socket_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify app starts and displays WebSocket Demo screen', (tester) async {
      // Act
      app.main();
      
      // Wait for the app to settle down
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert
      // Check if the title text exists
      expect(find.text('WebSocket Demo'), findsOneWidget);

      // Check if the text field for typing a message exists
      expect(find.byType(TextField), findsOneWidget);

      // Check if the send button exists
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });
}
