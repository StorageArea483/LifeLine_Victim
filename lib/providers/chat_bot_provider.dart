import 'package:flutter_riverpod/legacy.dart';
import 'package:life_line/models/message.dart';

class ChatPageNotifier extends StateNotifier<ChatPageState> {
  ChatPageNotifier()
    : super(
        ChatPageState(
          messages: [],
          isLoading: false,
          currentStep: 0,
          isWaitingForOtherInput: false,
          detectedRequest: null,
        ),
      );

  void addMessage(Message message) {
    state = state.copyWith(messages: [...state.messages, message]);
  }

  void incrementCurrentStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void clearMessages() {
    state = state.copyWith(
      messages: [],
      currentStep: 0,
      detectedRequest: null,
      isWaitingForOtherInput: false,
    );
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setIsWaitingForOtherInput(bool waiting) {
    state = state.copyWith(isWaitingForOtherInput: waiting);
  }

  void setDetectedRequest(String? request) {
    state = state.copyWith(detectedRequest: request);
  }
}

class ChatPageState {
  final List<Message> messages;
  final bool isLoading;
  final int currentStep;
  final bool isWaitingForOtherInput;
  final String? detectedRequest;

  ChatPageState({
    this.messages = const [],
    this.isLoading = false,
    this.currentStep = 0,
    this.isWaitingForOtherInput = false,
    this.detectedRequest,
  });

  ChatPageState copyWith({
    List<Message>? messages,
    bool? isLoading,
    int? currentStep,
    bool? isWaitingForOtherInput,
    String? detectedRequest,
  }) {
    return ChatPageState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      currentStep: currentStep ?? this.currentStep,
      isWaitingForOtherInput:
          isWaitingForOtherInput ?? this.isWaitingForOtherInput,
      detectedRequest: detectedRequest ?? this.detectedRequest,
    );
  }
}

final chatPageProvider = StateNotifierProvider<ChatPageNotifier, ChatPageState>(
  (ref) {
    return ChatPageNotifier();
  },
);
