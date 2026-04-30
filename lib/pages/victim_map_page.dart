import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:life_line/models/victim_map_provider.dart';
import 'package:life_line/styles/styles.dart';
import 'package:life_line/widgets/fetch_lat_long.dart';
import 'package:life_line/widgets/global/bottom_navbar.dart';

class VictimMapPage extends ConsumerStatefulWidget {
  const VictimMapPage({super.key});

  @override
  ConsumerState<VictimMapPage> createState() => _VictimMapPageState();
}

class _VictimMapPageState extends ConsumerState<VictimMapPage> {
  final MapController _mapController = MapController();
  LocationResult? result; // ← nullable, no longer late

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getLocation();
    });
  }

  Future<void> getLocation() async {
    if (mounted) {
      ref.read(victimMapProvider.notifier).state = true;
    }
    try {
      LocationResult fetchedResult = await fetchLatLong();
      if (fetchedResult.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(fetchedResult.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Assign to field so the map can move to actual location
      result = fetchedResult;

      // Move camera to real location once available
      _mapController.move(
        LatLng(fetchedResult.latitude, fetchedResult.longitude),
        15,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        fetchedResult.latitude,
        fetchedResult.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String fullAddress =
            'Street: ${place.street}\nArea: ${place.subLocality}\nDistrict: ${place.subAdministrativeArea}';
        final userId = FirebaseAuth.instance.currentUser?.uid;

        if (userId != null && userId.isNotEmpty) {
          final querySnapshot =
              await FirebaseFirestore.instance
                  .collection('users')
                  .where('uid', isEqualTo: userId)
                  .limit(1)
                  .get();

          if (querySnapshot.docs.isNotEmpty) {
            final docId = querySnapshot.docs.first.id;
            final currentLocation = querySnapshot.docs.first.data()['location'];

            if (currentLocation == null || currentLocation.toString().isEmpty) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(docId)
                  .update({'location': fullAddress});
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location found but address is unavailable.'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to get location, please restart the app.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        ref.read(victimMapProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Consumer(
              builder: (context, ref, child) {
                if (!mounted) return const SizedBox.shrink();
                final isLoading = ref.watch(victimMapProvider);
                return isLoading
                    ? const Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryMaroon,
                          strokeWidth: 4,
                        ),
                      ),
                    )
                    : Positioned.fill(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          // Fallback center until GPS resolves
                          initialCenter: LatLng(
                            result?.latitude ?? 33.6844,
                            result?.longitude ?? 73.0479,
                          ),
                          initialZoom: 15,
                          minZoom: 1,
                          maxZoom: 18,
                          interactionOptions: const InteractionOptions(
                            flags:
                                InteractiveFlag.pinchZoom |
                                InteractiveFlag.drag |
                                InteractiveFlag.doubleTapZoom,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.lifeline.app',
                          ),
                          const CurrentLocationLayer(
                            style: LocationMarkerStyle(
                              marker: DefaultLocationMarker(),
                            ),
                          ),
                        ],
                      ),
                    );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
    );
  }
}
