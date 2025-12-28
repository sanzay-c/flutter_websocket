import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_app/core/enum/connection_status_enum.dart';
import 'package:socket_app/features/websocket_chat/domain/entities/message_entity.dart';
import 'package:socket_app/features/websocket_chat/domain/repositories/websocket_repository.dart';
import 'package:socket_app/features/websocket_chat/domain/usecases/connect_websocket.dart';
import 'package:socket_app/features/websocket_chat/domain/usecases/disconnect_websocket.dart';
import 'package:socket_app/features/websocket_chat/domain/usecases/send_message.dart';
import 'package:socket_app/features/websocket_chat/presentation/bloc/web_socket_state.dart';
import 'package:injectable/injectable.dart';

part 'web_socket_event.dart';

@injectable
class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
  final ConnectWebSocket _connectWebSocket;
  final SendMessage _sendMessage;
  final DisconnectWebSocket _disconnectWebSocket;
  final WebSocketRepository _repository;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionStatusSubscription;

  WebSocketBloc(
    this._connectWebSocket,
    this._sendMessage,
    this._disconnectWebSocket,
    this._repository,
  ) : super(WebSocketInitial()) {
    on<ConnectEvent>(_onConnect);
    on<SendMessageEvent>(_onSendMessage);
    on<MessageReceivedEvent>(_onMessageReceived);
    on<ConnectionStatusChangedEvent>(_onConnectionStatusChanged);
    on<DisconnectEvent>(_onDisconnect);
    on<ClearMessagesEvent>(_onClearMessages);
  }
  Future<void> _onConnect(
    ConnectEvent event,
    Emitter<WebSocketState> emit,
  ) async {
    emit(const WebSocketConnecting());

    final result = await _connectWebSocket();

    result.fold((failure) => emit(WebSocketError(failure.message)), (
      messageStream,
    ) {
      // Listen to message stream
      _messageSubscription?.cancel();
      _messageSubscription = messageStream.listen(
        (message) => add(MessageReceivedEvent(message)),
        onError: (error) {
          add(ConnectionStatusChangedEvent(ConnectionStatus.error));
        },
      );

      // Listen to connection status stream
      _connectionStatusSubscription?.cancel();
      _connectionStatusSubscription = _repository.connectionStatusStream.listen(
        (status) => add(ConnectionStatusChangedEvent(status)),
      );

      emit(const WebSocketConnected(messages: []));
    });
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<WebSocketState> emit,
  ) async {
    if (state is! WebSocketConnected) return;

    final result = await _sendMessage(event.message);

    result.fold(
      (failure) {
        // Show error but don't change state
        print('Failed to send message: ${failure.message}');
      },
      (_) {
        // Message successfully sent
        // Echo server will send it back, so we don't need to add it here
      },
    );
  }

  void _onMessageReceived(
    MessageReceivedEvent event,
    Emitter<WebSocketState> emit,
  ) {
    if (state is WebSocketConnected) {
      final currentState = state as WebSocketConnected;
      emit(
        currentState.copyWith(
          messages: [...currentState.messages, event.message],
        ),
      );
    }
  }

  void _onConnectionStatusChanged(
    ConnectionStatusChangedEvent event,
    Emitter<WebSocketState> emit,
  ) {
    if (state is WebSocketConnected) {
      final currentState = state as WebSocketConnected;
      emit(currentState.copyWith(connectionStatus: event.status));
    } else if (event.status == ConnectionStatus.error) {
      emit(const WebSocketError('Connection error occurred'));
    }
  }

  Future<void> _onDisconnect(
    DisconnectEvent event,
    Emitter<WebSocketState> emit,
  ) async {
    await _messageSubscription?.cancel();
    await _connectionStatusSubscription?.cancel();
    _messageSubscription = null;
    _connectionStatusSubscription = null;

    await _disconnectWebSocket();
    emit(const WebSocketDisconnected());
  }

  void _onClearMessages(
    ClearMessagesEvent event,
    Emitter<WebSocketState> emit,
  ) {
    if (state is WebSocketConnected) {
      final currentState = state as WebSocketConnected;
      emit(currentState.copyWith(messages: []));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    return super.close();
  }
}
