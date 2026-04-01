import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:life_line/config/gpt_client.dart';
import 'package:life_line/providers/chat_bot_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:life_line/styles/styles.dart';
import 'package:life_line/models/message.dart';

class ChatBot extends ConsumerStatefulWidget {
  final String request; // "flood", "earthquake", "medical"

  const ChatBot({super.key, required this.request});

  @override
  ConsumerState<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends ConsumerState<ChatBot> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _chatId = const Uuid().v4();
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendInitialMessage();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    if (_channel != null) {
      _channel?.sink.close();
    }
    super.dispose();
  }

  void _initializeWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(GptClient.gptUrl));

      _channel!.stream.listen(
        (data) {
          if (!mounted) return;

          try {
            final response = data.toString();
            ref
                .read(chatPageProvider.notifier)
                .addMessage(Message(text: response, isUser: false));
            ref.read(chatPageProvider.notifier).setLoading(false);
            _scrollToBottom();
          } catch (e) {
            _handleError('Error processing response: $e');
          }
        },
        onError: (error) {
          _handleError('Connection error: $error');
        },
        onDone: () {
          if (mounted) {
            _handleError('Connection closed unexpectedly');
          }
        },
      );
    } catch (e) {
      _handleError('Failed to connect: $e');
    }
  }

  void _sendInitialMessage() {
    String initialMessage;
    switch (widget.request.toLowerCase()) {
      case 'flood':
        initialMessage = 'I am in a flood situation';
        break;
      case 'earthquake':
        initialMessage = 'There has been an earthquake';
        break;
      case 'medical':
        initialMessage = 'I need medical help';
        break;
      default:
        initialMessage = 'I need help';
    }
    _sendMessage(initialMessage);
  }

  Future<void> _sendMessage(String text) async {
    if (!mounted) return;
    final isLoading = ref.read(chatPageProvider).isLoading;
    if (text.trim().isEmpty || isLoading) return;

    if (!mounted) return;
    ref
        .read(chatPageProvider.notifier)
        .addMessage(Message(text: text, isUser: true));
    if (!mounted) return;
    ref.read(chatPageProvider.notifier).setLoading(true);
    _scrollToBottom();

    try {
      if (_channel == null) {
        _initializeWebSocket();
      }

      final message = {
        'chatId': _chatId,
        'appId': 'space-bag',
        'systemPrompt': GptClient.systemPrompt,
        'message': text,
      };

      _channel?.sink.add(jsonEncode(message));
    } catch (e) {
      _handleError('Failed to send message: $e');
    }
  }

  void _handleError(String errorMessage) {
    if (!mounted) return;
    ref
        .read(chatPageProvider.notifier)
        .addMessage(Message(text: errorMessage, isUser: false));
    if (!mounted) return;
    ref.read(chatPageProvider.notifier).setLoading(false);

    if (_channel != null) {
      _channel?.sink.close();
      _channel = null;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      _controller.clear();
      _sendMessage(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        title: const Text('Emergency Assistant', style: AppText.appHeader),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Consumer(
            builder: (context, ref, child) {
              final messages = ref.watch(
                chatPageProvider.select((v) => v.messages),
              );
              return Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              );
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              final isLoading = ref.watch(
                chatPageProvider.select((v) => v.isLoading),
              );
              return Column(
                children: [
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryMaroon,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Typing...', style: AppText.small),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            // Bot avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryMaroon.withOpacity(0.1),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/robo_head.webp',
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color:
                    message.isUser
                        ? AppColors.primaryMaroon
                        : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 14,
                  height: 1.4,
                  color:
                      message.isUser ? AppColors.white : AppColors.darkCharcoal,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            // User avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryMaroon.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 20,
                color: AppColors.primaryMaroon,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.softBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderColor, width: 1),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !ref.read(chatPageProvider).isLoading,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: AppText.small.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 14,
                    color: AppColors.darkCharcoal,
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryMaroon,
                    AppColors.primaryMaroon.withOpacity(0.8),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryMaroon.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed:
                    ref.read(chatPageProvider).isLoading ? null : _handleSend,
                icon: const Icon(Icons.send, color: AppColors.white),
                iconSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
