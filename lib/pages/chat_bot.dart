import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/pages/landing_page.dart';
import 'package:life_line/widgets/global/bottom_navbar.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:life_line/config/gpt_client.dart';
import 'package:life_line/providers/chat_bot_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:life_line/styles/styles.dart';
import 'package:life_line/models/message.dart';
import 'dart:developer';

class ChatBot extends ConsumerStatefulWidget {
  final String? request; // "flood", "earthquake", "medical"

  const ChatBot({super.key, this.request});

  @override
  ConsumerState<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends ConsumerState<ChatBot> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _chatId = const Uuid().v4();
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
      // Close existing connection if any
      if (_channel != null) {
        _channel?.sink.close();
        _channel = null;
      }

      _channel = WebSocketChannel.connect(Uri.parse(GptClient.gptUrl));
      final StringBuffer responseBuffer = StringBuffer();

      _channel!.stream.listen(
        (data) {
          if (!mounted) return;
          // Accumulate each incoming chunk
          responseBuffer.write(data.toString());
        },
        onDone: () {
          // Stream closed by server — full message received
          if (!mounted) return;
          final fullMessage = responseBuffer.toString().trim();
          if (fullMessage.isNotEmpty && mounted) {
            ref
                .read(chatPageProvider.notifier)
                .addMessage(Message(text: fullMessage, isUser: false));
            ref.read(chatPageProvider.notifier).setLoading(false);
          }
          _scrollToBottom();
          responseBuffer.clear();
          // Reset channel so next message creates a fresh connection
          _channel = null;
        },
        onError: (error) {
          _handleError('Connection error');
          responseBuffer.clear();
          _channel = null;
        },
      );
    } catch (e) {
      _handleError('Failed to connect to Assistant, please retry');
    }
  }

  void _sendInitialMessage() {
    if (widget.request == null) {
      return; // Don't send initial message if no request specified
    }

    String initialMessage;
    switch (widget.request!.toLowerCase()) {
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

  // Method to detect request type from user message using regex
  String? _detectRequestFromMessage(String message) {
    final lowerMessage = message.toLowerCase();
    log('Testing message: "$lowerMessage"');

    // Regex patterns for flood-related keywords
    final floodPattern = RegExp(
      r'\b(flood|flooding|flooded|water|drowning|submerged|inundated|deluge)\b',
    );

    // Regex patterns for earthquake-related keywords
    final earthquakePattern = RegExp(
      r'\b(earthquake|quake|tremor|seismic|shaking|aftershock|epicenter|magnitude)\b',
    );

    // Regex patterns for medical-related keywords
    final medicalPattern = RegExp(
      r'\b(medical|health|injury|injured|hurt|pain|sick|illness|emergency|ambulance|doctor|hospital)\b',
    );

    if (floodPattern.hasMatch(lowerMessage)) {
      log('Flood pattern matched!');
      return 'flood';
    } else if (earthquakePattern.hasMatch(lowerMessage)) {
      log('Earthquake pattern matched!');
      return 'earthquake';
    } else if (medicalPattern.hasMatch(lowerMessage)) {
      log('Medical pattern matched!');
      return 'medical';
    }

    log('No pattern matched');
    return null;
  }

  Future<void> _sendMessage(String text) async {
    if (!mounted) return;
    final isLoading = ref.read(chatPageProvider).isLoading;
    if (text.trim().isEmpty || isLoading) return;

    if (mounted) {
      ref
          .read(chatPageProvider.notifier)
          .addMessage(Message(text: text, isUser: true));
      ref.read(chatPageProvider.notifier).setLoading(true);
      _scrollToBottom();
    }

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
      _handleError('Failed to send message');
    }
  }

  void _handleError(String errorMessage) {
    if (mounted) {
      ref
          .read(chatPageProvider.notifier)
          .addMessage(Message(text: errorMessage, isUser: false));
      ref.read(chatPageProvider.notifier).setLoading(false);
    }

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

  void _handleOptionTap(String option) {
    if (option.toLowerCase() == 'other' && mounted) {
      // Enable text field for custom input
      ref.read(chatPageProvider.notifier).setIsWaitingForOtherInput(true);
      // Focus on text field for custom input
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(FocusNode());
      });
      return;
    }

    // Send the selected option as a message
    if (option.isNotEmpty) {
      _sendMessage(option);
    }

    // Move to next step (only for flood/earthquake flows)
    final currentRequest =
        widget.request ?? ref.read(chatPageProvider).detectedRequest;
    if (mounted &&
        currentRequest != null &&
        (currentRequest.toLowerCase() == 'flood' ||
            currentRequest.toLowerCase() == 'earthquake')) {
      ref.read(chatPageProvider.notifier).incrementCurrentStep();
    }
    // Scroll to bottom after selection
    _scrollToBottom();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && mounted) {
      _controller.clear();
      _sendMessage(text);
      // Reset the waiting for other input state
      if (mounted) {
        ref.read(chatPageProvider.notifier).setIsWaitingForOtherInput(false);
      }
      String? detected;
      // Detect request type from user message if not already set
      if (widget.request == null &&
          ref.read(chatPageProvider).detectedRequest == null) {
        detected = _detectRequestFromMessage(text);
        if (detected != null) {
          ref
              .read(chatPageProvider.notifier)
              .setDetectedRequest(detected); // flood/earthquake
        }
      }
      final currentRequest = detected;
      log('Current Result Value: $currentRequest');
      if (mounted &&
          currentRequest != null &&
          (currentRequest.toLowerCase() == 'flood' ||
              currentRequest.toLowerCase() == 'earthquake')) {
        ref.read(chatPageProvider.notifier).incrementCurrentStep();
        log('Step incremented!');
      }
    }
  }

  bool _isTextFieldEnabled(WidgetRef ref) {
    // Get the effective request (widget.request has priority over detectedRequest)
    final detectedRequest = ref.read(chatPageProvider).detectedRequest;
    final currentRequest = widget.request ?? detectedRequest;
    log('Request in isTextFieldEnabled: $currentRequest');

    // Always enable for medical mode or if no request detected yet
    if (currentRequest == null || currentRequest.toLowerCase() == 'medical') {
      return true;
    }

    // Enable if waiting for "Other" input
    if (mounted && ref.read(chatPageProvider).isWaitingForOtherInput) {
      return true;
    }

    // Enable if current step has empty options (location step)
    List<List<String>> answerOptions;
    switch (currentRequest.toLowerCase()) {
      case 'flood':
        answerOptions = GptClient.floodAnswers;
        break;
      case 'earthquake':
        answerOptions = GptClient.earthquakeAnswers;
        break;
      default:
        return true;
    }
    if (!mounted) return false;
    final currentStep = ref.watch(
      chatPageProvider.select((v) => v.currentStep),
    );
    if (currentStep < answerOptions.length) {
      final options = answerOptions[currentStep];
      return options.isEmpty; // Enable if no options (location step)
    }

    return false;
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LandingPage()),
              );
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.surfaceLight,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag handle
                          Container(
                            width: 36,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: AppColors.borderColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            title: const Text(
                              'Clear all messages',
                              style: TextStyle(
                                fontFamily: 'SFPro',
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                            onTap: () {
                              if (mounted) {
                                ref
                                    .read(chatPageProvider.notifier)
                                    .setDetectedRequest(null);
                                // Generate new chatId to start fresh conversation
                                _chatId = const Uuid().v4();
                                // Invalidate provider to reset all state
                                ref.invalidate(chatPageProvider);
                              }
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer(
            builder: (context, ref, child) {
              if (!mounted) return const SizedBox.shrink();
              final messages = ref.watch(
                chatPageProvider.select((v) => v.messages),
              );
              return messages.isEmpty
                  ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: AppText.fieldLabel.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Send a message to Emergency assistant and tell them what medical services you need',
                              style: AppText.small.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  : Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isLastBotMessage =
                            !message.isUser && index == messages.length - 1;
                        return _buildMessageBubble(message, isLastBotMessage);
                      },
                    ),
                  );
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              if (!mounted) return const SizedBox.shrink();
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primaryMaroon
                                      .withOpacity(0.1),
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
                                const Text('Typing...', style: AppText.small),
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
      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
    );
  }

  Widget _buildMessageBubble(Message message, bool isLastBotMessage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                message.isUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                          message.isUser
                              ? AppColors.white
                              : AppColors.darkCharcoal,
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
          Consumer(
            builder: (context, ref, child) {
              if (!mounted) return const SizedBox.shrink();
              final isLoading = ref.watch(
                chatPageProvider.select((v) => v.isLoading),
              );
              // Also watch detectedRequest to rebuild when it changes
              log(
                'Detected Request: ${ref.watch(chatPageProvider.select((v) => v.detectedRequest))}',
              );
              final detectedRequest = ref.watch(
                chatPageProvider.select((v) => v.detectedRequest),
              );

              // Show options only for the last bot message and when not loading
              if (mounted &&
                  !message.isUser &&
                  isLastBotMessage &&
                  !isLoading &&
                  detectedRequest != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [const SizedBox(height: 8), _buildOptions(ref)],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(WidgetRef ref) {
    // Get the effective request (widget.request has priority over detectedRequest)
    final detectedRequest = ref.read(chatPageProvider).detectedRequest;
    final currentRequest = widget.request ?? detectedRequest;

    log(
      '_buildOptions called - widget.request: ${widget.request}, detectedRequest: $detectedRequest, currentRequest: $currentRequest',
    );

    if (currentRequest == null) {
      log('_buildOptions returning empty - no request');
      return const SizedBox.shrink();
    }

    List<List<String>> answerOptions;
    switch (currentRequest.toLowerCase()) {
      case 'flood':
        answerOptions = GptClient.floodAnswers;
        break;
      case 'earthquake':
        answerOptions = GptClient.earthquakeAnswers;
        break;
      default:
        return const SizedBox.shrink();
    }

    // Get current step from provider
    if (!mounted) return const SizedBox.shrink();
    final currentStep = ref.watch(
      chatPageProvider.select((v) => v.currentStep),
    );

    // Check if we have options for current step
    if (currentStep >= answerOptions.length) {
      log(
        '_buildOptions returning empty - step $currentStep >= ${answerOptions.length}',
      );
      return const SizedBox.shrink();
    }

    final options = answerOptions[currentStep];
    if (options.isEmpty) {
      log('_buildOptions returning empty - no options for step $currentStep');
      return const SizedBox.shrink();
    }

    log(
      '_buildOptions showing ${options.length} options for step $currentStep: $options',
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 40), // Align with message bubble
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            options.map((option) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleOptionTap(option),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryMaroon.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight.withOpacity(0.5),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontFamily: 'SFPro',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryMaroon,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
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
                child: Consumer(
                  builder: (context, ref, child) {
                    return TextField(
                      controller: _controller,
                      enabled: _isTextFieldEnabled(ref),
                      decoration: InputDecoration(
                        hintText:
                            _isTextFieldEnabled(ref)
                                ? 'Type your message...'
                                : 'Please select an option above',
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
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Consumer(
              builder: (context, ref, child) {
                return Container(
                  decoration: BoxDecoration(
                    color:
                        _isTextFieldEnabled(ref)
                            ? AppColors.primaryMaroon
                            : AppColors.primaryMaroon.withOpacity(0.6),

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
                    onPressed: _isTextFieldEnabled(ref) ? _handleSend : null,
                    icon: const Icon(Icons.send, color: AppColors.white),
                    iconSize: 20,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
