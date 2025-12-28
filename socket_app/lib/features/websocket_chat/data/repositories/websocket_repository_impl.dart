import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:socket_app/core/enum/connection_status_enum.dart';
import 'package:socket_app/features/websocket_chat/data/datasources/websocket_remote_datasoure.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/websocket_repository.dart';

@LazySingleton(as: WebSocketRepository)
class WebSocketRepositoryImpl implements WebSocketRepository {
  final WebSocketRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  WebSocketRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  ResultFuture<Stream<MessageEntity>> connect() async {
    if (!await _networkInfo.isConnected) {
      return const Left(ConnectionFailure('No internet connection'));
    }

    try {
      final messageStream = await _remoteDataSource.connect();

      // Convert MessageModel stream to MessageEntity stream
      final entityStream = messageStream.map((model) => model.toEntity());

      return Right(entityStream);
    } on WebSocketException catch (e) {
      return Left(WebSocketFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  ResultFuture<void> sendMessage(String message) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ConnectionFailure('No internet connection'));
    }

    try {
      await _remoteDataSource.sendMessage(message);
      return const Right(null);
    } on WebSocketException catch (e) {
      return Left(WebSocketFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to send message: $e'));
    }
  }

  @override
  ResultVoid disconnect() async {
    try {
      await _remoteDataSource.disconnect();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to disconnect: $e'));
    }
  }

  @override
  Stream<ConnectionStatus> get connectionStatusStream =>
      _remoteDataSource.connectionStatusStream;
}
