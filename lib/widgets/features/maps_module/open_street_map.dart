import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:life_line/services/functions/transitions_in_pages.dart';
import 'package:life_line/widgets/features/victim_dashboard/victim_page.dart';
import 'package:life_line/widgets/global/bottom_navbar.dart';

class OpenStreetMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const OpenStreetMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<OpenStreetMapScreen> createState() => _OpenStreetMapScreenState();
}

class _OpenStreetMapScreenState extends State<OpenStreetMapScreen> {
  int currentIndex = 1;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(widget.latitude, widget.longitude),
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
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.lifeline.app',
                ),
                CurrentLocationLayer(
                  style: LocationMarkerStyle(marker: DefaultLocationMarker()),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          if (index == 0) {
            pageTransition(context, VictimPage());
          }
        },
      ),
    );
  }
}
