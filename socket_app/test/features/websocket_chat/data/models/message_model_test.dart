import 'package:flutter_test/flutter_test.dart';
import 'package:socket_app/core/enum/message_type_enum.dart';
import 'package:socket_app/features/websocket_chat/data/models/message_model.dart';
import 'package:socket_app/features/websocket_chat/domain/entities/message_entity.dart';

void main() {
  group('MessageModel Unit Tests', () {
    final tTimestamp = DateTime(2026, 4, 27, 12, 0, 0);

    final tMessageModel = MessageModel(
      id: '1',
      content: 'Hello Bajar',
      timestamp: tTimestamp,
      type: 'text',
      isSentByMe: true,
    );

    final tMessageEntity = MessageEntity(
      id: '1',
      content: 'Hello Bajar',
      timestamp: tTimestamp,
      type: MessageType.text,
      isSentByMe: true,
    );

    test('should convert Model to Entity correctly', () {
      // Act
      final result = tMessageModel.toEntity();

      // Assert
      expect(result.id, tMessageEntity.id);
      expect(result.content, tMessageEntity.content);
      expect(result.timestamp, tMessageEntity.timestamp);
      expect(result.type, tMessageEntity.type);
      expect(result.isSentByMe, tMessageEntity.isSentByMe);
    });

    test('should create Model from Entity correctly', () {
      // Act
      final result = MessageModel.fromEntity(tMessageEntity);

      // Assert
      expect(result.id, tMessageModel.id);
      expect(result.content, tMessageModel.content);
      expect(result.timestamp, tMessageModel.timestamp);
      expect(result.type, tMessageModel.type);
      expect(result.isSentByMe, tMessageModel.isSentByMe);
    });

    test('should create Model from JSON correctly', () {
      // Arrange
      final jsonMap = {
        'id': '1',
        'content': 'Hello Bajar',
        'timestamp': tTimestamp.toIso8601String(),
        'type': 'text',
        'isSentByMe': true,
      };

      // Act
      final result = MessageModel.fromJson(jsonMap);

      // Assert
      expect(result.id, '1');
      expect(result.content, 'Hello Bajar');
      expect(result.timestamp, tTimestamp);
      expect(result.type, 'text');
      expect(result.isSentByMe, true);
    });

    test('should convert Model to JSON correctly', () {
      // Act
      final result = tMessageModel.toJson();

      // Assert
      final expectedJsonMap = {
        'id': '1',
        'content': 'Hello Bajar',
        'timestamp': tTimestamp.toIso8601String(),
        'type': 'text',
        'isSentByMe': true,
      };
      expect(result, expectedJsonMap);
    });
  });
}
