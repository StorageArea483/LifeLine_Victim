import 'package:flutter_riverpod/legacy.dart';
import 'package:life_line/models/message.dart';

class ChatPageNotifier extends StateNotifier<ChatPageState> {
  ChatPageNotifier() : super(ChatPageState(messages: [], isLoading: false));

  void addMessage(Message message) {
    state = state.copyWith(messages: [...state.messages, message]);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

class ChatPageState {
  final List<Message> messages;
  final bool isLoading;

  ChatPageState({this.messages = const [], this.isLoading = false});

  ChatPageState copyWith({List<Message>? messages, bool? isLoading}) {
    return ChatPageState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final chatPageProvider = StateNotifierProvider<ChatPageNotifier, ChatPageState>(
  (ref) {
    return ChatPageNotifier();
  },
);
