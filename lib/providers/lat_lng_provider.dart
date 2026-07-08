import 'package:flutter_riverpod/legacy.dart';

class LatLngNotifier extends StateNotifier<LatLngState> {
  LatLngNotifier() : super(LatLngState());

  void setLatitude(double latitude) {
    state = state.copyWith(latitude: latitude);
  }

  void setLongitude(double longitude) {
    state = state.copyWith(longitude: longitude);
  }
}

class LatLngState {
  final double? latitude;
  final double? longitude;

  LatLngState({this.latitude, this.longitude});

  LatLngState copyWith({double? latitude, double? longitude}) {
    return LatLngState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

final latLngProvider = StateNotifierProvider<LatLngNotifier, LatLngState>((
  ref,
) {
  return LatLngNotifier();
});
