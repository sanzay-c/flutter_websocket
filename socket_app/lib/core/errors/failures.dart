import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message);
}

class WebSocketFailure extends Failure {
  const WebSocketFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
