import 'package:equatable/equatable.dart';
import 'package:socket_app/core/enum/message_type_enum.dart';


class MessageEntity extends Equatable {
  final String id;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final bool isSentByMe;

  const MessageEntity({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.isSentByMe,
  });

  @override
  List<Object?> get props => [id, content, timestamp, type, isSentByMe];
}