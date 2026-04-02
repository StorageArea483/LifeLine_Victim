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
        ),
      );

  void addMessage(Message message) {
    state = state.copyWith(messages: [...state.messages, message]);
  }

  void incrementCurrentStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void clearMessages() {
    state = state.copyWith(messages: [], currentStep: 0);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setIsWaitingForOtherInput(bool waiting) {
    state = state.copyWith(isWaitingForOtherInput: waiting);
  }
}

class ChatPageState {
  final List<Message> messages;
  final bool isLoading;
  final int currentStep;
  bool isWaitingForOtherInput;

  ChatPageState({
    this.messages = const [],
    this.isLoading = false,
    this.currentStep = 0,
    this.isWaitingForOtherInput = false,
  });

  ChatPageState copyWith({
    List<Message>? messages,
    bool? isLoading,
    int? currentStep,
    bool? isWaitingForOtherInput,
  }) {
    return ChatPageState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      currentStep: currentStep ?? this.currentStep,
      isWaitingForOtherInput:
          isWaitingForOtherInput ?? this.isWaitingForOtherInput,
    );
  }
}

final chatPageProvider = StateNotifierProvider<ChatPageNotifier, ChatPageState>(
  (ref) {
    return ChatPageNotifier();
  },
);
