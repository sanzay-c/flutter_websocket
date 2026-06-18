import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:socket_app/core/errors/exceptions.dart';
import 'package:socket_app/core/errors/failures.dart';
import 'package:socket_app/core/network/network_info.dart';
import 'package:socket_app/features/websocket_chat/data/datasources/websocket_remote_datasoure.dart';
import 'package:socket_app/features/websocket_chat/data/models/message_model.dart';
import 'package:socket_app/features/websocket_chat/data/repositories/websocket_repository_impl.dart';
import 'package:socket_app/features/websocket_chat/domain/entities/message_entity.dart';

class MockRemoteDataSource extends Mock implements WebSocketRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late WebSocketRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = WebSocketRepositoryImpl(mockRemoteDataSource, mockNetworkInfo);
  });

  group('connect', () {
    final tMessageModel = MessageModel(
      id: '1',
      content: 'Hello',
      timestamp: DateTime.now(),
      type: 'text',
      isSentByMe: true,
    );
    final tMessageModelStream = Stream.fromIterable([tMessageModel]);

    test('should check if the device is online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.connect(),
      ).thenAnswer((_) async => tMessageModelStream);

      // Act
      await repository.connect();

      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    test(
      'should return Right(Stream<MessageEntity>) when connection is successful',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.connect(),
        ).thenAnswer((_) async => tMessageModelStream);

        // Act
        final result = await repository.connect();

        // Assert
        expect(result.isRight(), true);
        final stream = result.getOrElse(() => throw Exception());
        expect(await stream.first, isA<MessageEntity>());
        verify(() => mockRemoteDataSource.connect());
      },
    );

    test(
      'should return Left(ConnectionFailure) when device is offline',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.connect();

        // Assert
        expect(result, const Left(ConnectionFailure('No internet connection')));
        verifyZeroInteractions(mockRemoteDataSource);
      },
    );

    test(
      'should return Left(WebSocketFailure) when datasource throws WebSocketException',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.connect(),
        ).thenThrow(const WebSocketException('WS Error'));

        // Act
        final result = await repository.connect();

        // Assert
        expect(result, const Left(WebSocketFailure('WS Error')));
      },
    );
  });

  group('sendMessage', () {
    const tMessage = 'Hello';

    test(
      'should return Right(null) when message is sent successfully',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.sendMessage(any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.sendMessage(tMessage);

        // Assert
        expect(result, const Right(null));
        verify(() => mockRemoteDataSource.sendMessage(tMessage));
      },
    );

    test('should return Left(ConnectionFailure) when offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.sendMessage(tMessage);

      // Assert
      expect(result, const Left(ConnectionFailure('No internet connection')));
    });
  });

  group('disconnect', () {
    test('should call disconnect on datasource', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.disconnect(),
      ).thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.disconnect();

      // Assert
      expect(result, const Right(null));
      verify(() => mockRemoteDataSource.disconnect());
    });
  });
}
