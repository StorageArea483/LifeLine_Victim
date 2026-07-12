import 'package:flutter_riverpod/legacy.dart';

class GlobalStateNotifier extends StateNotifier<GlobalState> {
  GlobalStateNotifier() : super(GlobalState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setResendLoading(bool resendLoading) {
    state = state.copyWith(isResendLoading: resendLoading);
  }
}

class GlobalState {
  final bool isLoading;
  final bool isResendLoading;

  GlobalState({this.isLoading = false, this.isResendLoading = false});

  GlobalState copyWith({bool? isLoading, bool? isResendLoading}) {
    return GlobalState(
      isLoading: isLoading ?? this.isLoading,
      isResendLoading: isResendLoading ?? this.isResendLoading,
    );
  }
}

final globalStateProvider =
    StateNotifierProvider.autoDispose<GlobalStateNotifier, GlobalState>((ref) {
      return GlobalStateNotifier();
    });
