import 'package:injectable/injectable.dart';
import '../../../../core/utils/typedef.dart';
import '../repositories/websocket_repository.dart';

@lazySingleton
class DisconnectWebSocket {
  final WebSocketRepository _repository;

  DisconnectWebSocket(this._repository);

  ResultVoid call() async {
    return await _repository.disconnect();
  }
}