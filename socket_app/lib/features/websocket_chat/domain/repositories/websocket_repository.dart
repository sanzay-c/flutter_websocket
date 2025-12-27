import 'package:socket_app/core/enum/connection_status_enum.dart';

import '../../../../core/utils/typedef.dart';
import '../entities/message_entity.dart';

abstract class WebSocketRepository {
  ResultFuture<Stream<MessageEntity>> connect();
  ResultFuture<void> sendMessage(String message);
  ResultVoid disconnect();
  Stream<ConnectionStatus> get connectionStatusStream;
}