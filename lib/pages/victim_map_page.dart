import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:life_line_victim/config/map_routes_api.dart';
import 'package:life_line_victim/pages/landing_page.dart';
import 'package:life_line_victim/providers/global_address_provider.dart';
import 'package:life_line_victim/providers/lat_lng_provider.dart';
import 'package:life_line_victim/providers/victim_map_provider.dart';
import 'package:life_line_victim/styles/styles.dart';
import 'package:life_line_victim/widgets/fetch_lat_long.dart';
import 'package:life_line_victim/widgets/global/bottom_navbar.dart';
import 'package:life_line_victim/services/location_service.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:life_line_victim/utils/responsive_helper.dart';
import 'package:life_line_victim/widgets/global/page_message.dart';
import 'package:life_line_victim/widgets/global/page_navigation.dart';

class VictimMapPage extends ConsumerStatefulWidget {
  final double? rescuerLatitude;
  final double? rescuerLongitude;

  const VictimMapPage({super.key, this.rescuerLatitude, this.rescuerLongitude});

  @override
  ConsumerState<VictimMapPage> createState() => _VictimMapPageState();
}

class _VictimMapPageState extends ConsumerState<VictimMapPage> {
  final MapController _mapController = MapController();
  late LocationSettings locationSettings;
  StreamSubscription<Position>? _locationSubscription;
  bool _isMarkingArrived = false;

  bool get _hasValidRescuerLocation =>
      widget.rescuerLatitude != null &&
      widget.rescuerLongitude != null &&
      !(widget.rescuerLatitude == 0.0 && widget.rescuerLongitude == 0.0);

  Future<void> _drawRoute(double victimLat, double victimLng) async {
    if (!_hasValidRescuerLocation) {
      return;
    }

    try {
      final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car'
        '?api_key=${HeigitApi.orsApiKey}'
        '&start=$victimLng,$victimLat'
        '&end=${widget.rescuerLongitude},${widget.rescuerLatitude}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List coordinates = data['features'][0]['geometry']['coordinates'];
        final summary = data['features'][0]['properties']['segments'][0];
        final distanceKm = (summary['distance'] / 1000).toStringAsFixed(1);
        final durationMin = (summary['duration'] / 60).toStringAsFixed(0);

        if (mounted) {
          ref.read(routePointsProvider.notifier).state =
              coordinates
                  .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
                  .toList();
          ref.read(rescuerMapProvider.notifier).setDistance('$distanceKm km');
          ref.read(rescuerMapProvider.notifier).setDuration('$durationMin min');
        }
      }
    } catch (e) {
      pageMessage(
        'Failed to construct poly lines, Please retry',
        context,
        AppColors.error,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getLocation();
      await _startLocationTracking();
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // only update if moved 10 meters
        intervalDuration: const Duration(seconds: 10), // check every 10 sec
        forceLocationManager:
            false, // use Google Fused Location (more optimized)
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'LifeLine is active',
          notificationText: 'Sharing location for emergency assistance',
          enableWakeLock: false, // dont force CPU awake, saves battery
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        activityType:
            ActivityType.fitness, // optimized for walking/slow movement
        pauseLocationUpdatesAutomatically:
            true, // iOS pauses when user is still
      );
    }

    try {
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) async {
        final newPosition = LatLng(position.latitude, position.longitude);
        if (mounted) {
          _mapController.move(newPosition, _mapController.camera.zoom);
          await _updateLocationInFirestore(
            position.latitude,
            position.longitude,
          );
        }
        if (_hasValidRescuerLocation) {
          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            widget.rescuerLatitude!,
            widget.rescuerLongitude!,
          );
          // within 50 meters = reached victim
          if (distance <= 50 && mounted) {
            _locationSubscription?.cancel();
            _showArrivedDialog();
          }
        }
      });
    } catch (e) {
      pageMessage(
        'Failed to initialize map, Please try again',
        context,
        AppColors.error,
      );
      pageNavigation(const LandingPage(), context);
    }
  }

  void _showArrivedDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  backgroundColor: AppColors.surfaceLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(
                      color: AppColors.borderColor,
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  title: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMaroon.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.primaryMaroon,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Rescuer Reached',
                        textAlign: TextAlign.center,
                        style: AppText.formTitle,
                      ),
                    ],
                  ),
                  content: const Text(
                    'Rescuer has reached to your current location',
                    textAlign: TextAlign.center,
                    style: AppText.formDescription,
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  actions: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: AppButtons.submit,
                        onPressed:
                            _isMarkingArrived
                                ? null
                                : () async {
                                  setDialogState(
                                    () => _isMarkingArrived = true,
                                  );
                                  if (dialogContext.mounted) {
                                    Navigator.of(dialogContext).pop();
                                  }
                                  setDialogState(
                                    () => _isMarkingArrived = false,
                                  );
                                },
                        child: const Text(
                          'Confirm',
                          style: AppText.submitButton,
                        ),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _updateLocationInFirestore(
    double latitude,
    double longitude,
  ) async {
    try {
      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = [
          placemark.street,
          placemark.locality,
          placemark.administrativeArea,
          placemark.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        if (address.isNotEmpty) {
          await LocationService.updateUserLocation(address, null);

          if (mounted) {
            ref.read(latLngProvider.notifier).setLatitude(latitude);
            ref.read(latLngProvider.notifier).setLongitude(longitude);
            ref.read(globalAddressProvider.notifier).state = address;
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getLocation() async {
    try {
      LocationResult fetchedResult = await fetchLatLong();
      if (fetchedResult.error != null) {
        pageMessage(fetchedResult.error!, context, AppColors.error);
        return;
      }
      _mapController.move(
        LatLng(fetchedResult.latitude, fetchedResult.longitude),
        15,
      );

      await _drawRoute(fetchedResult.latitude, fetchedResult.longitude);

      // Update location in Firestore using the shared service
      if (fetchedResult.address != null && fetchedResult.address!.isNotEmpty) {
        await LocationService.updateUserLocation(fetchedResult.address, null);

        if (mounted) {
          ref.read(latLngProvider.notifier).setLatitude(fetchedResult.latitude);
          ref
              .read(latLngProvider.notifier)
              .setLongitude(fetchedResult.longitude);
          ref.read(globalAddressProvider.notifier).state =
              fetchedResult.address;
        }
      }
    } catch (e) {
      pageMessage(
        'Failed to extract location, Please try again',
        context,
        AppColors.error,
      );
      pageNavigation(const LandingPage(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: ResponsiveHelper.contentWidth(context),
            height: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.horizontalPadding(context),
                      vertical: ResponsiveHelper.verticalPadding(context),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.isTablet(context) ? 24 : 16,
                      ),
                      child: _buildFlutterMap(),
                    ),
                  ),
                ),
                _buildRouteInfoOverlay(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
    );
  }

  Widget _buildFlutterMap() {
    try {
      return FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(34.1463, 73.2117),
          initialZoom: 15,
          minZoom: 1,
          maxZoom: 18,
          interactionOptions: InteractionOptions(
            flags:
                InteractiveFlag.pinchZoom |
                InteractiveFlag.drag |
                InteractiveFlag.doubleTapZoom,
          ),
        ),
        children: [
          _buildTileLayer(),
          _buildRescuerMarker(),
          _buildRoutePolyline(),
          _buildCurrentLocationLayer(),
        ],
      );
    } catch (e) {
      return Container(
        color: Colors.red.withOpacity(0.3),
        child: Center(child: Text('Map Error: $e')),
      );
    }
  }

  Widget _buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.lifeline.app',
    );
  }

  Widget _buildRescuerMarker() {
    if (_hasValidRescuerLocation) {
      return MarkerLayer(
        markers: [
          Marker(
            point: LatLng(widget.rescuerLatitude!, widget.rescuerLongitude!),
            width: 40,
            height: 40,
            child: const Icon(Icons.location_on, color: Colors.red, size: 32),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildCurrentLocationLayer() {
    return const CurrentLocationLayer(
      style: LocationMarkerStyle(
        marker: DefaultLocationMarker(color: AppColors.primaryMaroon),
        markerSize: Size(20, 20),
        markerDirection: MarkerDirection.heading,
      ),
    );
  }

  Widget _buildRoutePolyline() {
    return Consumer(
      builder: (context, ref, child) {
        if (!mounted) {
          return const SizedBox.shrink();
        }

        final routePoints = ref.watch(routePointsProvider);

        if (_hasValidRescuerLocation && routePoints.isNotEmpty) {
          return PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 4.0,
                color: Colors.red,
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRouteInfoOverlay() {
    return Consumer(
      builder: (context, ref, child) {
        if (!mounted) {
          return const SizedBox.shrink();
        }

        final distance = ref.watch(
          rescuerMapProvider.select((state) => state.distance),
        );
        final duration = ref.watch(
          rescuerMapProvider.select((state) => state.duration),
        );

        if (distance.isEmpty && duration.isEmpty) {
          return const SizedBox.shrink();
        }

        return Positioned(
          top: ResponsiveHelper.isTablet(context) ? 32 : 16,
          left: ResponsiveHelper.isTablet(context) ? 32 : 16,
          right: ResponsiveHelper.isTablet(context) ? 32 : 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.route,
                      color: AppColors.primaryMaroon,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      distance,
                      style: AppText.small.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 20, color: AppColors.borderColor),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppColors.primaryMaroon,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      duration,
                      style: AppText.small.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
