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
          hasConnectionError: false,
          disableOptionsOnOtherTap: false,
        ),
      );

  void addMessage(Message message) {
    state = state.copyWith(messages: [...state.messages, message]);
  }

  void incrementCurrentStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void decrementCurrentStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setIsWaitingForOtherInput(bool waiting) {
    state = state.copyWith(isWaitingForOtherInput: waiting);
  }

  void setHasConnectionError(bool hasError) {
    state = state.copyWith(hasConnectionError: hasError);
  }

  void setDisableOptions(bool disable) {
    state = state.copyWith(disableOptionsOnOtherTap: disable);
  }
}

class ChatPageState {
  final List<Message> messages;
  final bool isLoading;
  final int currentStep;
  final bool isWaitingForOtherInput;
  final bool hasConnectionError;
  final bool disableOptionsOnOtherTap;

  ChatPageState({
    this.messages = const [],
    this.isLoading = false,
    this.currentStep = 0,
    this.isWaitingForOtherInput = false,
    this.hasConnectionError = false,
    this.disableOptionsOnOtherTap = false,
  });

  ChatPageState copyWith({
    List<Message>? messages,
    bool? isLoading,
    int? currentStep,
    bool? isWaitingForOtherInput,
    bool? hasConnectionError,
    bool? disableOptionsOnOtherTap,
  }) {
    return ChatPageState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      currentStep: currentStep ?? this.currentStep,
      isWaitingForOtherInput:
          isWaitingForOtherInput ?? this.isWaitingForOtherInput,
      hasConnectionError: hasConnectionError ?? this.hasConnectionError,
      disableOptionsOnOtherTap:
          disableOptionsOnOtherTap ?? this.disableOptionsOnOtherTap,
    );
  }
}

final chatPageProvider = StateNotifierProvider<ChatPageNotifier, ChatPageState>(
  (ref) {
    return ChatPageNotifier();
  },
);

final isSpeechListening = StateProvider<bool>((ref) => false);
