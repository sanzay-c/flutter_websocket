import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_app/core/enum/connection_status_enum.dart';
import 'package:socket_app/core/enum/message_type_enum.dart';
import 'package:socket_app/features/websocket_chat/presentation/bloc/web_socket_bloc.dart';
import 'package:socket_app/features/websocket_chat/presentation/bloc/web_socket_state.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/message_entity.dart';

class WebSocketPage extends StatelessWidget {
  const WebSocketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<WebSocketBloc>()..add(const ConnectEvent()),
      child: const WebSocketPageContent(),
    );
  }
}

class WebSocketPageContent extends StatefulWidget {
  const WebSocketPageContent({super.key});

  @override
  State<WebSocketPageContent> createState() => _WebSocketPageContentState();
}

class _WebSocketPageContentState extends State<WebSocketPageContent> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    context.read<WebSocketBloc>().add(
      SendMessageEvent(_messageController.text.trim()),
    );

    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<WebSocketBloc, WebSocketState>(
          builder: (context, state) {
            String subtitle = 'Disconnected';
            Color statusColor = Colors.grey;

            if (state is WebSocketConnecting) {
              subtitle = 'Connecting...';
              statusColor = Colors.orange;
            } else if (state is WebSocketConnected) {
              switch (state.connectionStatus) {
                case ConnectionStatus.connected:
                  subtitle = 'Connected';
                  statusColor = Colors.green;
                  break;
                case ConnectionStatus.reconnecting:
                  subtitle = 'Reconnecting...';
                  statusColor = Colors.orange;
                  break;
                case ConnectionStatus.error:
                  subtitle = 'Connection Error';
                  statusColor = Colors.red;
                  break;
                case ConnectionStatus.connecting:
                  subtitle = 'Connecting...';
                  statusColor = Colors.orange;
                  break;
                case ConnectionStatus.disconnected:
                  throw UnimplementedError();
              }
            } else if (state is WebSocketError) {
              subtitle = 'Error';
              statusColor = Colors.red;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('WebSocket Demo'),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(subtitle, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          BlocBuilder<WebSocketBloc, WebSocketState>(
            builder: (context, state) {
              if (state is WebSocketConnected) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'clear') {
                      context.read<WebSocketBloc>().add(
                        const ClearMessagesEvent(),
                      );
                    } else if (value == 'disconnect') {
                      context.read<WebSocketBloc>().add(
                        const DisconnectEvent(),
                      );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'clear',
                      child: Text('Clear Messages'),
                    ),
                    PopupMenuItem(
                      value: 'disconnect',
                      child: Text('Disconnect'),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<WebSocketBloc, WebSocketState>(
        listener: (context, state) {
          if (state is WebSocketError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WebSocketConnecting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WebSocketDisconnected) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<WebSocketBloc>().add(const ConnectEvent());
                },
                child: const Text('Reconnect'),
              ),
            );
          }

          if (state is WebSocketConnected) {
            return Column(
              children: [
                Expanded(
                  child: state.messages.isEmpty
                      ? const Center(
                          child: Text(
                            'No messages yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            return MessageBubble(
                              message: state.messages[index],
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final MessageEntity message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isSentByMe = message.isSentByMe;
    final bool isSystem = message.type == MessageType.system;
    final bool isError = message.type == MessageType.error;

    if (isSystem || isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isError ? Colors.red.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.content,
              style: TextStyle(
                fontSize: 12,
                color: isError ? Colors.red : Colors.black54,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isSentByMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSentByMe ? Colors.blue : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.content,
              style: TextStyle(
                color: isSentByMe ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
