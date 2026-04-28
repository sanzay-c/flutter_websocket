import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socket_app/core/enum/message_type_enum.dart';
import 'package:socket_app/features/websocket_chat/domain/entities/message_entity.dart';
import 'package:socket_app/features/websocket_chat/presentation/pages/websocket_page.dart';

void main() {
  Widget createWidgetUnderTest(MessageEntity message) {
    return MaterialApp(
      home: Scaffold(
        body: MessageBubble(message: message),
      ),
    );
  }

  group('MessageBubble Widget Tests', () {
    testWidgets('renders user message correctly (blue bubble, right aligned)', (WidgetTester tester) async {
      // Arrange
      final message = MessageEntity(
        id: '1',
        content: 'Hello World',
        timestamp: DateTime.now(),
        type: MessageType.text,
        isSentByMe: true,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(message));

      // Assert
      expect(find.text('Hello World'), findsOneWidget);
      
      final containerFinder = find.descendant(
        of: find.byType(Row),
        matching: find.byType(Container),
      ).first;
      
      final Container container = tester.widget(containerFinder);
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.blue); // Sent by me should be blue

      final Row row = tester.widget(find.byType(Row).first);
      expect(row.mainAxisAlignment, MainAxisAlignment.end); // Sent by me should be right aligned
    });

    testWidgets('renders received message correctly (grey bubble, left aligned)', (WidgetTester tester) async {
      // Arrange
      final message = MessageEntity(
        id: '2',
        content: 'Hi there!',
        timestamp: DateTime.now(),
        type: MessageType.text,
        isSentByMe: false,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(message));

      // Assert
      expect(find.text('Hi there!'), findsOneWidget);
      
      final containerFinder = find.descendant(
        of: find.byType(Row),
        matching: find.byType(Container),
      ).first;
      
      final Container container = tester.widget(containerFinder);
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.grey.shade300); // Received should be grey

      final Row row = tester.widget(find.byType(Row).first);
      expect(row.mainAxisAlignment, MainAxisAlignment.start); // Received should be left aligned
    });
  });
}
