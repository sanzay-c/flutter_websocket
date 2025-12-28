import 'package:equatable/equatable.dart';
import 'package:socket_app/core/enum/connection_status_enum.dart';
import '../../domain/entities/message_entity.dart';

abstract class WebSocketState extends Equatable {
  const WebSocketState();

  @override
  List<Object?> get props => [];
}

class WebSocketInitial extends WebSocketState {
  const WebSocketInitial();
}

class WebSocketConnecting extends WebSocketState {
  const WebSocketConnecting();
}

class WebSocketConnected extends WebSocketState {
  final List<MessageEntity> messages;
  final ConnectionStatus connectionStatus;

  const WebSocketConnected({
    required this.messages,
    this.connectionStatus = ConnectionStatus.connected,
  });

  WebSocketConnected copyWith({
    List<MessageEntity>? messages,
    ConnectionStatus? connectionStatus,
  }) {
    return WebSocketConnected(
      messages: messages ?? this.messages,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }

  @override
  List<Object?> get props => [messages, connectionStatus];
}

class WebSocketError extends WebSocketState {
  final String message;

  const WebSocketError(this.message);

  @override
  List<Object?> get props => [message];
}

class WebSocketDisconnected extends WebSocketState {
  const WebSocketDisconnected();
}
