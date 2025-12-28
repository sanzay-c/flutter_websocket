import 'package:socket_app/core/enum/connection_status_enum.dart';

import '../models/message_model.dart';

abstract class WebSocketRemoteDataSource {
  Future<Stream<MessageModel>> connect();
  Future<void> sendMessage(String message);
  Future<void> disconnect();
  Stream<ConnectionStatus> get connectionStatusStream;
  void dispose();
}
