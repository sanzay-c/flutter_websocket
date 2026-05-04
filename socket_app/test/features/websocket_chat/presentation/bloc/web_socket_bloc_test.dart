import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:socket_app/core/enum/connection_status_enum.dart';
import 'package:socket_app/core/enum/message_type_enum.dart';
import 'package:socket_app/core/errors/failures.dart';
import 'package:socket_app/features/websocket_chat/domain/entities/message_entity.dart';
import 'package:socket_app/features/websocket_chat/domain/repositories/websocket_repository.dart';
import 'package:socket_app/features/websocket_chat/domain/usecases/connect_websocket.dart';
import 'package:socket_app/features/websocket_chat/domain/usecases/disconnect_websocket.dart';
import 'package:socket_app/features/websocket_chat/domain/usecases/send_message.dart';
import 'package:socket_app/features/websocket_chat/presentation/bloc/web_socket_bloc.dart';
import 'package:socket_app/features/websocket_chat/presentation/bloc/web_socket_state.dart';

class MockConnectWebSocket extends Mock implements ConnectWebSocket {}
class MockSendMessage extends Mock implements SendMessage {}
class MockDisconnectWebSocket extends Mock implements DisconnectWebSocket {}
class MockWebSocketRepository extends Mock implements WebSocketRepository {}

void main() {
  late WebSocketBloc bloc;
  late MockConnectWebSocket mockConnectWebSocket;
  late MockSendMessage mockSendMessage;
  late MockDisconnectWebSocket mockDisconnectWebSocket;
  late MockWebSocketRepository mockWebSocketRepository;

  setUp(() {
    mockConnectWebSocket = MockConnectWebSocket();
    mockSendMessage = MockSendMessage();
    mockDisconnectWebSocket = MockDisconnectWebSocket();
    mockWebSocketRepository = MockWebSocketRepository();

    bloc = WebSocketBloc(
      mockConnectWebSocket,
      mockSendMessage,
      mockDisconnectWebSocket,
      mockWebSocketRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final tMessage = MessageEntity(
    id: '1',
    content: 'Hello',
    timestamp: DateTime.now(),
    type: MessageType.text,
    isSentByMe: true,
  );

  test('initial state should be WebSocketInitial', () {
    expect(bloc.state, WebSocketInitial());
  });

  group('ConnectEvent', () {
    final tMessageStreamController = StreamController<MessageEntity>();
    final tConnectionStatusStreamController = StreamController<ConnectionStatus>();

    blocTest<WebSocketBloc, WebSocketState>(
      'emits [WebSocketConnecting, WebSocketConnected] when connection is successful',
      build: () {
        when(() => mockConnectWebSocket()).thenAnswer((_) async => Right(tMessageStreamController.stream));
        when(() => mockWebSocketRepository.connectionStatusStream)
            .thenAnswer((_) => tConnectionStatusStreamController.stream);
        return bloc;
      },
      act: (bloc) => bloc.add(ConnectEvent()),
      expect: () => [
        const WebSocketConnecting(),
        const WebSocketConnected(messages: []),
      ],
    );

    blocTest<WebSocketBloc, WebSocketState>(
      'emits [WebSocketConnecting, WebSocketError] when connection fails',
      build: () {
        when(() => mockConnectWebSocket())
            .thenAnswer((_) async => const Left(ServerFailure('Connection Failed')));
        return bloc;
      },
      act: (bloc) => bloc.add(ConnectEvent()),
      expect: () => [
        const WebSocketConnecting(),
        const WebSocketError('Connection Failed'),
      ],
    );
  });

  group('MessageReceivedEvent', () {
    blocTest<WebSocketBloc, WebSocketState>(
      'emits WebSocketConnected with new message when MessageReceivedEvent is added',
      build: () => bloc,
      seed: () => const WebSocketConnected(messages: []),
      act: (bloc) => bloc.add(MessageReceivedEvent(tMessage)),
      expect: () => [
        WebSocketConnected(messages: [tMessage]),
      ],
    );
  });

  group('SendMessageEvent', () {
    const tMessageText = 'Hello';
    blocTest<WebSocketBloc, WebSocketState>(
      'calls SendMessage usecase when SendMessageEvent is added',
      build: () {
        when(() => mockSendMessage(any())).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => const WebSocketConnected(messages: []),
      act: (bloc) => bloc.add(const SendMessageEvent(tMessageText)),
      verify: (_) {
        verify(() => mockSendMessage(tMessageText)).called(1);
      },
    );
  });

  group('DisconnectEvent', () {
    blocTest<WebSocketBloc, WebSocketState>(
      'emits WebSocketDisconnected and calls DisconnectWebSocket usecase',
      build: () {
        when(() => mockDisconnectWebSocket()).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(DisconnectEvent()),
      expect: () => [
        const WebSocketDisconnected(),
      ],
      verify: (_) {
        verify(() => mockDisconnectWebSocket()).called(1);
      },
    );
  });

  group('Security and Data Privacy', () {
    blocTest<WebSocketBloc, WebSocketState>(
      'emits WebSocketError with security message when unauthorized',
      build: () {
        when(() => mockConnectWebSocket())
            .thenAnswer((_) async => const Left(ServerFailure('Unauthorized access - Token Expired')));
        return bloc;
      },
      act: (bloc) => bloc.add(ConnectEvent()),
      expect: () => [
        const WebSocketConnecting(),
        const WebSocketError('Unauthorized access - Token Expired'),
      ],
    );

    blocTest<WebSocketBloc, WebSocketState>(
      'clears all messages from state when ClearMessagesEvent is added',
      build: () => bloc,
      seed: () => WebSocketConnected(messages: [tMessage]),
      act: (bloc) => bloc.add(ClearMessagesEvent()),
      expect: () => [
        const WebSocketConnected(messages: []),
      ],
    );

    test('bloc.close() should cancel all subscriptions (Memory Leak Prevention)', () async {
      // Arrange
      when(() => mockConnectWebSocket()).thenAnswer((_) async => Right(StreamController<MessageEntity>().stream));
      when(() => mockWebSocketRepository.connectionStatusStream).thenAnswer((_) => const Stream.empty());
      
      // Act
      bloc.add(ConnectEvent());
      await pumpEventQueue(); // Wait for bloc to process
      
      // Assert & Act
      await expectLater(bloc.close(), completes);
    });
  });
}
