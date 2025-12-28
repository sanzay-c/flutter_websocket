import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:injectable/injectable.dart';
import 'package:socket_app/core/enum/connection_status_enum.dart';
import 'package:socket_app/features/websocket_chat/data/datasources/websocket_remote_datasoure.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/message_model.dart';

@LazySingleton(as: WebSocketRemoteDataSource)
class WebSocketRemoteDataSourceImpl implements WebSocketRemoteDataSource {
  WebSocketChannel? _channel;

  final StreamController<MessageModel> _messageController =
      StreamController<MessageModel>.broadcast();

  final StreamController<ConnectionStatus> _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();

  Timer? _reconnectTimer;
  Timer? _pingTimer;
  int _reconnectAttempts = 0;
  bool _isIntentionalDisconnect = false;
  bool _isConnected = false;

  @override
  Stream<ConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  @override
  Future<Stream<MessageModel>> connect() async {
    try {
      _isIntentionalDisconnect = false;
      _updateConnectionStatus(ConnectionStatus.connecting);

      final uri = Uri.parse(ApiConstants.wsUrl);

      _channel = WebSocketChannel.connect(uri);

      // Wait for connection with timeout
      await _channel!.ready.timeout(
        ApiConstants.connectionTimeout,
        onTimeout: () {
          throw const WebSocketException('Connection timeout');
        },
      );

      _isConnected = true;

      // Listen to messages
      _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      // Start ping timer
      _startPingTimer();

      _updateConnectionStatus(ConnectionStatus.connected);
      _reconnectAttempts = 0;

      // Send connection success message
      _addSystemMessage('Connected to WebSocket server');

      return _messageController.stream;
    } catch (e) {
      _isConnected = false;
      _updateConnectionStatus(ConnectionStatus.error);
      throw WebSocketException('Failed to connect: $e');
    }
  }

  void _onData(dynamic data) {
    try {
      // Echo server le text return garcha
      final String message = data.toString();

      // Try to parse as JSON first
      try {
        final jsonData = json.decode(message);
        final messageModel = MessageModel.fromJson(jsonData);
        _messageController.add(messageModel);
      } catch (_) {
        // If not JSON, treat as plain text (echo response)
        final messageModel = MessageModel.fromPlainText(message, false);
        _messageController.add(messageModel);
      }
    } catch (e) {
      log('Error parsing message: $e');
      _addErrorMessage('Failed to parse message: $e');
    }
  }

  // ignore: strict_top_level_inference
  void _onError(error) {
    log('WebSocket error: $error');
    _isConnected = false;
    _updateConnectionStatus(ConnectionStatus.error);
    _addErrorMessage('Connection error: $error');

    if (!_isIntentionalDisconnect) {
      _attemptReconnect();
    }
  }

  void _onDone() {
    log('WebSocket connection closed');
    _isConnected = false;
    _pingTimer?.cancel();

    if (!_isIntentionalDisconnect) {
      _updateConnectionStatus(ConnectionStatus.disconnected);
      _addSystemMessage('Connection closed');
      _attemptReconnect();
    }
  }

  void _attemptReconnect() {
    if (_reconnectAttempts >= ApiConstants.maxReconnectAttempts) {
      _updateConnectionStatus(ConnectionStatus.error);
      _addErrorMessage(
        'Max reconnection attempts (${ApiConstants.maxReconnectAttempts}) reached',
      );
      return;
    }

    _reconnectAttempts++;
    _updateConnectionStatus(ConnectionStatus.reconnecting);
    _addSystemMessage(
      'Attempting to reconnect... ($_reconnectAttempts/${ApiConstants.maxReconnectAttempts})',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(ApiConstants.reconnectDelay, () {
      if (!_isIntentionalDisconnect) {
        connect();
      }
    });
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(ApiConstants.pingInterval, (timer) {
      if (_channel != null && _isConnected) {
        try {
          // Echo server ko lagi simple ping message
          _channel!.sink.add('ping');
        } catch (e) {
          log('Error sending ping: $e');
        }
      }
    });
  }

  @override
  Future<void> sendMessage(String message) async {
    if (_channel == null || !_isConnected) {
      throw const WebSocketException('WebSocket not connected');
    }

    try {
      _channel!.sink.add(message);

      // Add sent message to stream
      final sentMessage = MessageModel.fromPlainText(message, true);
      _messageController.add(sentMessage);
    } catch (e) {
      throw WebSocketException('Failed to send message: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    _isIntentionalDisconnect = true;
    _isConnected = false;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();

    try {
      await _channel?.sink.close(status.goingAway);
    } catch (e) {
      log('Error closing WebSocket: $e');
    }

    _channel = null;
    _updateConnectionStatus(ConnectionStatus.disconnected);
    _addSystemMessage('Disconnected from server');
  }

  void _updateConnectionStatus(ConnectionStatus status) {
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(status);
    }
  }

  void _addSystemMessage(String message) {
    final systemMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      timestamp: DateTime.now(),
      type: 'system',
      isSentByMe: false,
    );
    _messageController.add(systemMessage);
  }

  void _addErrorMessage(String message) {
    final errorMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      timestamp: DateTime.now(),
      type: 'error',
      isSentByMe: false,
    );
    _messageController.add(errorMessage);
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _messageController.close();
    _connectionStatusController.close();
    _channel?.sink.close();
  }
}
