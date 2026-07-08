import 'package:flutter_riverpod/legacy.dart';
import 'package:life_line_victim/models/message.dart';

class ChatPageNotifier extends StateNotifier<ChatPageState> {
  ChatPageNotifier()
    : super(
        ChatPageState(
          messages: [],
          isLoading: false,
          currentStep: 0,
          hasConnectionError: false,
          disableOptionsOnOtherTap: false,
          isSpeechListening: false,
          isSeverityUpdating: false,
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

  void setHasConnectionError(bool hasError) {
    state = state.copyWith(hasConnectionError: hasError);
  }

  void setDisableOptions(bool disable) {
    state = state.copyWith(disableOptionsOnOtherTap: disable);
  }

  void setIsSpeechListening(bool isSpeechListening) {
    state = state.copyWith(isSpeechListening: isSpeechListening);
  }

  void setIsSeverityUpdating(bool isSeverityUpdating) {
    state = state.copyWith(isSeverityUpdating: isSeverityUpdating);
  }
}

class ChatPageState {
  final List<Message> messages;
  final bool isLoading;
  final int currentStep;
  final bool hasConnectionError;
  final bool disableOptionsOnOtherTap;
  final bool isSpeechListening;
  final bool isSeverityUpdating;

  ChatPageState({
    this.messages = const [],
    this.isLoading = false,
    this.currentStep = 0,
    this.hasConnectionError = false,
    this.disableOptionsOnOtherTap = false,
    this.isSpeechListening = false,
    this.isSeverityUpdating = false,
  });

  ChatPageState copyWith({
    List<Message>? messages,
    bool? isLoading,
    int? currentStep,
    bool? hasConnectionError,
    bool? disableOptionsOnOtherTap,
    bool? isSpeechListening,
    bool? isSeverityUpdating,
  }) {
    return ChatPageState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      currentStep: currentStep ?? this.currentStep,
      hasConnectionError: hasConnectionError ?? this.hasConnectionError,
      disableOptionsOnOtherTap:
          disableOptionsOnOtherTap ?? this.disableOptionsOnOtherTap,
      isSpeechListening: isSpeechListening ?? this.isSpeechListening,
      isSeverityUpdating: isSeverityUpdating ?? this.isSeverityUpdating,
    );
  }
}

final chatPageProvider =
    StateNotifierProvider.autoDispose<ChatPageNotifier, ChatPageState>((ref) {
      return ChatPageNotifier();
    });
