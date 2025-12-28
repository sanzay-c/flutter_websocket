part of 'web_socket_bloc.dart';

@immutable
sealed class WebSocketEvent extends Equatable {
  const WebSocketEvent();

  @override
  List<Object?> get props => [];
}

class ConnectEvent extends WebSocketEvent {
  const ConnectEvent();
}

class SendMessageEvent extends WebSocketEvent {
  final String message;

  const SendMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageReceivedEvent extends WebSocketEvent {
  final MessageEntity message;

  const MessageReceivedEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class ConnectionStatusChangedEvent extends WebSocketEvent {
  final ConnectionStatus status;

  const ConnectionStatusChangedEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class DisconnectEvent extends WebSocketEvent {
  const DisconnectEvent();
}

class ClearMessagesEvent extends WebSocketEvent {
  const ClearMessagesEvent();
}
