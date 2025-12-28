import 'package:injectable/injectable.dart';
import '../../../../core/utils/typedef.dart';
import '../entities/message_entity.dart';
import '../repositories/websocket_repository.dart';

@lazySingleton
class ConnectWebSocket {
  final WebSocketRepository _repository;

  ConnectWebSocket(this._repository);

  ResultFuture<Stream<MessageEntity>> call() async {
    return await _repository.connect();
  }
}
