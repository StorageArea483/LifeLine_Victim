import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:life_line/pages/landing_page.dart';
import 'package:life_line/widgets/global/bottom_navbar.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:life_line/config/grok_client.dart';
import 'package:life_line/providers/chat_bot_provider.dart';

import 'package:life_line/styles/styles.dart';
import 'package:life_line/models/message.dart';

class ChatBot extends ConsumerStatefulWidget {
  final String? request; // "flood", "earthquake", "medical"

  const ChatBot({super.key, this.request});

  @override
  ConsumerState<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends ConsumerState<ChatBot> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFocusNode = FocusNode();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechInitialized = false;

  final List<Map<String, String>> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _conversationHistory.add({
      'role': 'system',
      'content': GrokClient.systemPrompt,
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendInitialMessage();
    });
  }

  Future<void> _initializeSpeech() async {
    try {
      _speechInitialized = await _speechToText.initialize(
        onError: (error) {
          if (mounted) {
            ref.read(isSpeechListening.notifier).state = false;
            _handleExceptionError('Sorry, an unexpected error occured');
          }
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) {
              ref.read(isSpeechListening.notifier).state = false;
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ref.read(isSpeechListening.notifier).state = false;
        _handleExceptionError('Sorry, an unexpected error occured');
      }
      _speechInitialized = false;
    }
  }

  void _handleExceptionError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(msg)),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _startListening() async {
    try {
      if (!_speechInitialized) {
        await _initializeSpeech();
      }
      if (_speechInitialized) {
        await _speechToText.listen(onResult: _onSpeechResult);
        if (mounted) {
          ref.read(isSpeechListening.notifier).state = true;
        }
      }
    } catch (e) {
      _handleExceptionError('Mic failed to initialize');
    }
  }

  void _stopListening() async {
    try {
      await _speechToText.stop();
      if (mounted) {
        ref.read(isSpeechListening.notifier).state = false;
      }
    } catch (e) {
      _handleExceptionError('An unexpected error occured');
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (mounted) {
      _controller.text = result.recognizedWords;
      // Move cursor to end of text
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  Future<void> _sendToOpenRouter(String userMessage) async {
    try {
      // Add user message to conversation history
      _conversationHistory.add({'role': 'user', 'content': userMessage});

      final response = await http.post(
        Uri.parse(GrokClient.apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${GrokClient.apiKey}',
          'HTTP-Referer': 'https://lifeline.app',
          'X-Title': 'LifeLine Emergency Assistant',
        },
        body: jsonEncode({
          'model': GrokClient.modelName,
          'messages': _conversationHistory,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantMessage =
            data['choices'][0]['message']['content'] as String;

        // Add assistant response to conversation history
        _conversationHistory.add({
          'role': 'assistant',
          'content': assistantMessage,
        });

        final isRetry = RegExp(
          r'please answer my question',
          caseSensitive: false,
        ).hasMatch(assistantMessage);

        final currentRequest = widget.request;
        final isStructured =
            currentRequest != null &&
            (currentRequest.toLowerCase() == 'flood' ||
                currentRequest.toLowerCase() == 'earthquake');

        if (isRetry && isStructured && mounted) {
          ref.read(chatPageProvider.notifier).decrementCurrentStep();
        }

        if (mounted) {
          ref
              .read(chatPageProvider.notifier)
              .addMessage(Message(text: assistantMessage, isUser: false));
          ref.read(chatPageProvider.notifier).setLoading(false);
        }
        _scrollToBottom();
      } else {
        _handleError('Failed to get response, please try again');
      }
    } catch (e) {
      _handleError('Failed to connect to Assistant, please retry');
    }
  }

  void _sendInitialMessage() {
    if (widget.request == null) return;

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
        initialMessage = 'I need medical help';
    }

    _sendMessage(initialMessage);
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
      ref.read(chatPageProvider.notifier).setHasConnectionError(false);
      _scrollToBottom();
    }

    await _sendToOpenRouter(text);
  }

  void _handleError(String errorMessage) {
    if (mounted) {
      ref
          .read(chatPageProvider.notifier)
          .addMessage(Message(text: errorMessage, isUser: false));
      ref.read(chatPageProvider.notifier).setLoading(false);
      ref.read(chatPageProvider.notifier).setHasConnectionError(true);
      ref.read(chatPageProvider.notifier).setIsWaitingForOtherInput(false);
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
    if (!mounted) return;
    final currentRequest = widget.request;
    final isStructured =
        currentRequest != null &&
        (currentRequest.toLowerCase() == 'flood' ||
            currentRequest.toLowerCase() == 'earthquake');

    if (option.toLowerCase() == 'other' && mounted) {
      ref.read(chatPageProvider.notifier).setIsWaitingForOtherInput(true);
      ref.read(chatPageProvider.notifier).setDisableOptions(true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _textFocusNode.requestFocus();
      });
      if (isStructured && mounted) {
        ref.read(chatPageProvider.notifier).incrementCurrentStep();
      }
      return;
    }
    if (option.isNotEmpty) {
      _sendMessage(option);
    }
    if (isStructured && mounted) {
      ref.read(chatPageProvider.notifier).incrementCurrentStep();
    }
    _scrollToBottom();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || !mounted) return;

    _controller.clear();

    if (!mounted) return;
    ref.read(chatPageProvider.notifier).setDisableOptions(false);

    if (!mounted) return;
    final isWaitingForOther = ref.read(chatPageProvider).isWaitingForOtherInput;
    _sendMessage(text);

    if (isWaitingForOther && mounted) {
      ref.read(chatPageProvider.notifier).setIsWaitingForOtherInput(false);
      _textFocusNode.unfocus();
    }
  }

  bool _isTextFieldEnabled(WidgetRef ref) {
    if (!mounted) return false;
    final isWaitingForOther = ref.watch(
      chatPageProvider.select((v) => v.isWaitingForOtherInput),
    );
    if (isWaitingForOther) return true;
    if (!mounted) return false;
    final currentRequest = widget.request;
    if (currentRequest == null || currentRequest.toLowerCase() == 'medical') {
      return true;
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
                                _conversationHistory.clear();
                                _conversationHistory.add({
                                  'role': 'system',
                                  'content': GrokClient.systemPrompt,
                                });
                                if (mounted) {
                                  ref.invalidate(chatPageProvider);
                                }
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

              if (!message.isUser && isLastBotMessage && !isLoading) {
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
    if (!mounted) return const SizedBox.shrink();

    final hasError = ref.watch(
      chatPageProvider.select((v) => v.hasConnectionError),
    );
    if (hasError && mounted) return const SizedBox.shrink();
    final disableOptions = ref.watch(
      chatPageProvider.select((v) => v.disableOptionsOnOtherTap),
    );
    if (disableOptions && mounted) return const SizedBox.shrink();
    final currentRequest = widget.request;
    if (currentRequest == null) return const SizedBox.shrink();

    List<List<String>> answerOptions;
    switch (currentRequest.toLowerCase()) {
      case 'flood':
        answerOptions = GrokClient.floodAnswers;
        break;
      case 'earthquake':
        answerOptions = GrokClient.earthquakeAnswers;
        break;
      default:
        return const SizedBox.shrink();
    }

    if (!mounted) return const SizedBox.shrink();
    final currentStep = ref.watch(
      chatPageProvider.select((v) => v.currentStep),
    );
    if (currentStep >= answerOptions.length) return const SizedBox.shrink();

    final options = answerOptions[currentStep];
    if (options.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 40),
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
                    if (!mounted) return const SizedBox.shrink();
                    final enabled = _isTextFieldEnabled(ref);
                    return TextField(
                      controller: _controller,
                      focusNode: _textFocusNode,
                      enabled: enabled,
                      decoration: InputDecoration(
                        hintText:
                            enabled
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
                if (!mounted) return const SizedBox.shrink();
                final enabled = _isTextFieldEnabled(ref);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mic Button
                    Consumer(
                      builder: (context, ref, _) {
                        if (!mounted) return const SizedBox.shrink();
                        final isListening = ref.watch(isSpeechListening);
                        return Container(
                          decoration: BoxDecoration(
                            color:
                                isListening
                                    ? Colors.red
                                    : (enabled)
                                    ? AppColors.primaryMaroon
                                    : AppColors.primaryMaroon.withOpacity(0.6),
                            shape: BoxShape.circle,
                            boxShadow:
                                isListening
                                    ? [
                                      // Glowing effect when mic is active
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.4),
                                        blurRadius: 20,
                                        spreadRadius: 4,
                                        offset: const Offset(0, 0),
                                      ),
                                      BoxShadow(
                                        color: AppColors.primaryMaroon
                                            .withOpacity(0.3),
                                        blurRadius: 30,
                                        spreadRadius: 8,
                                        offset: const Offset(0, 0),
                                      ),
                                    ]
                                    : [
                                      BoxShadow(
                                        color: AppColors.primaryMaroon
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                          ),
                          child: IconButton(
                            onPressed:
                                enabled
                                    ? (isListening
                                        ? _stopListening
                                        : _startListening)
                                    : null,
                            icon: Icon(
                              enabled ? Icons.mic : Icons.mic_off,
                              color: AppColors.white,
                            ),
                            iconSize: 20,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    // Send Button
                    Container(
                      decoration: BoxDecoration(
                        color:
                            enabled
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
                        onPressed: enabled ? _handleSend : null,
                        icon: const Icon(Icons.send, color: AppColors.white),
                        iconSize: 20,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
