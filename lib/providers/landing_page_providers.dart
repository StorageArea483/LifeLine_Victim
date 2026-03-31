import 'package:flutter_riverpod/legacy.dart';

class LandingPageNotifier extends StateNotifier<LandingPageState> {
  LandingPageNotifier() : super(LandingPageState(showEmergencyOptions: false));

  void setShowEmergencyOptions(bool value) {
    state = state.copyWith(showEmergencyOptions: value);
  }

  void setActiveButton(String label) {
    state = state.copyWith(activeButton: label);
  }

  void clearActiveButton() {
    state = state.copyWith(clearActiveButton: true);
  }
}

class LandingPageState {
  final bool showEmergencyOptions;
  final String? activeButton;

  LandingPageState({required this.showEmergencyOptions, this.activeButton});

  LandingPageState copyWith({
    bool? showEmergencyOptions,
    String? activeButton,
    bool clearActiveButton = false,
  }) {
    return LandingPageState(
      showEmergencyOptions: showEmergencyOptions ?? this.showEmergencyOptions,
      activeButton:
          clearActiveButton ? null : activeButton ?? this.activeButton,
    );
  }
}

final landingPageProvider =
    StateNotifierProvider<LandingPageNotifier, LandingPageState>((ref) {
      return LandingPageNotifier();
    });
