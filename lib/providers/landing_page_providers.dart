import 'package:flutter_riverpod/legacy.dart';

class LandingPageNotifier extends StateNotifier<LandingPageState> {
  LandingPageNotifier()
    : super(
        LandingPageState(
          showEmergencyOptions: false,
          rescuerAssigned: false,
          rescuerLatitude: null,
          rescuerLongitude: null,
        ),
      );

  void setShowEmergencyOptions(bool value) {
    state = state.copyWith(showEmergencyOptions: value);
  }

  void setActiveButton(String label) {
    state = state.copyWith(activeButton: label);
  }

  void clearActiveButton() {
    state = state.copyWith(clearActiveButton: true);
  }

  void setRescuerAssigned(bool value) {
    state = state.copyWith(rescuerAssigned: value);
  }

  void setRescuerLocation(double? latitude, double? longitude) {
    state = state.copyWith(
      rescuerLatitude: latitude,
      rescuerLongitude: longitude,
    );
  }
}

class LandingPageState {
  final bool showEmergencyOptions;
  final String? activeButton;
  final bool rescuerAssigned;
  final double? rescuerLatitude;
  final double? rescuerLongitude;

  LandingPageState({
    required this.showEmergencyOptions,
    this.activeButton,
    this.rescuerAssigned = false,
    this.rescuerLatitude,
    this.rescuerLongitude,
  });

  LandingPageState copyWith({
    bool? showEmergencyOptions,
    String? activeButton,
    bool clearActiveButton = false,
    bool? rescuerAssigned,
    double? rescuerLatitude,
    double? rescuerLongitude,
  }) {
    return LandingPageState(
      showEmergencyOptions: showEmergencyOptions ?? this.showEmergencyOptions,
      activeButton:
          clearActiveButton ? null : activeButton ?? this.activeButton,
      rescuerAssigned: rescuerAssigned ?? this.rescuerAssigned,
      rescuerLatitude: rescuerLatitude ?? this.rescuerLatitude,
      rescuerLongitude: rescuerLongitude ?? this.rescuerLongitude,
    );
  }
}

final landingPageProvider =
    StateNotifierProvider.autoDispose<LandingPageNotifier, LandingPageState>((
      ref,
    ) {
      return LandingPageNotifier();
    });
