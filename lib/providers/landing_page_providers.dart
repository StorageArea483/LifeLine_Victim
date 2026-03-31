import 'package:flutter_riverpod/legacy.dart';

class LandingPageNotifier extends StateNotifier<LandingPageState> {
  LandingPageNotifier()
    : super(LandingPageState(showEmergencyOptions: false, isLoading: false));

  void setShowEmergencyOptions(bool value) {
    state = state.copyWith(showEmergencyOptions: value);
  }

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }
}

class LandingPageState {
  final bool showEmergencyOptions;
  final bool isLoading;

  LandingPageState({
    required this.showEmergencyOptions,
    required this.isLoading,
  });

  LandingPageState copyWith({bool? showEmergencyOptions, bool? isLoading}) {
    return LandingPageState(
      showEmergencyOptions: showEmergencyOptions ?? this.showEmergencyOptions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final landingPageProvider =
    StateNotifierProvider<LandingPageNotifier, LandingPageState>((ref) {
      return LandingPageNotifier();
    });
