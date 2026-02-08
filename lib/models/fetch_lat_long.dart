import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String? error;

  LocationResult({required this.latitude, required this.longitude, this.error});
}

Future<LocationResult> fetchLatLong() async {
  try {
    // STEP 1: Check permission status
    LocationPermission permission = await Geolocator.checkPermission();

    // STEP 2: Request permission if denied
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // STEP 3: If still denied → return error
    if (permission == LocationPermission.denied) {
      return LocationResult(
        latitude: 0.0,
        longitude: 0.0,
        error: 'Location permission is required.',
      );
    }

    // STEP 4: If permanently denied → return error
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return LocationResult(
        latitude: 0.0,
        longitude: 0.0,
        error:
            'Permission permanently denied. Please enable it in app settings.',
      );
    }

    // STEP 5: Now safe to fetch location
    Position position = await Geolocator.getCurrentPosition();

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  } catch (e) {
    return LocationResult(
      latitude: 0.0,
      longitude: 0.0,
      error: 'Failed to get location: $e',
    );
  }
}
