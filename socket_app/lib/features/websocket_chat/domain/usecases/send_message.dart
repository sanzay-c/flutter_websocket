import 'package:injectable/injectable.dart';
import '../../../../core/utils/typedef.dart';
import '../repositories/websocket_repository.dart';

@lazySingleton
class SendMessage {
  final WebSocketRepository _repository;

  SendMessage(this._repository);

  ResultFuture<void> call(String message) async {
    return await _repository.sendMessage(message);
  }
}