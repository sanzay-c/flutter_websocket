import 'package:socket_app/core/enum/message_type_enum.dart';

import '../../../../core/utils/typedef.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel {
  final String id;
  final String content;
  final DateTime timestamp;
  final String type;
  final bool isSentByMe;

  const MessageModel({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.isSentByMe,
  });

  // Convert Model to Entity
  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      content: content,
      timestamp: timestamp,
      type: _mapStringToMessageType(type),
      isSentByMe: isSentByMe,
    );
  }

  // Create Model from Entity
  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      content: entity.content,
      timestamp: entity.timestamp,
      type: _mapMessageTypeToString(entity.type),
      isSentByMe: entity.isSentByMe,
    );
  }

  // Create Model from JSON
  factory MessageModel.fromJson(DataMap json) {
    return MessageModel(
      id:
          json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] as String? ?? json['message'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      type: json['type'] as String? ?? 'text',
      isSentByMe: json['isSentByMe'] as bool? ?? false,
    );
  }

  // Convert Model to JSON
  DataMap toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'isSentByMe': isSentByMe,
    };
  }

  // Create from plain text (for echo server)
  factory MessageModel.fromPlainText(String text, bool isSentByMe) {
    return MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      timestamp: DateTime.now(),
      type: 'text',
      isSentByMe: isSentByMe,
    );
  }

  MessageModel copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    String? type,
    bool? isSentByMe,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isSentByMe: isSentByMe ?? this.isSentByMe,
    );
  }

  static MessageType _mapStringToMessageType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'system':
        return MessageType.system;
      case 'error':
        return MessageType.error;
      default:
        return MessageType.text;
    }
  }

  static String _mapMessageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'text';
      case MessageType.system:
        return 'system';
      case MessageType.error:
        return 'error';
    }
  }
}
