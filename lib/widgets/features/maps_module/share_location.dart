import 'package:flutter/material.dart';
import 'package:life_line/styles/styles.dart';
import 'package:life_line/widgets/features/maps_module/open_street_map.dart';
import 'package:life_line/widgets/features/victim_dashboard/victim_page.dart';
import 'package:life_line/widgets/global/bottom_navbar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_line/widgets/fetch_lat_long.dart';

class ShareLocation extends StatefulWidget {
  const ShareLocation({super.key});

  @override
  State<ShareLocation> createState() => _ShareLocationState();
}

class _ShareLocationState extends State<ShareLocation> {
  int _currentIndex = 1;
  bool _isLoading = false;

  Future<void> _getLocation() async {
    setState(() => _isLoading = true);

    try {
      LocationResult result = await fetchLatLong();

      if (result.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.error!), backgroundColor: Colors.red),
          );
        }
        return;
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(
        result.latitude,
        result.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String fullAddress =
            'Street: ${place.street}\nArea: ${place.subLocality}\nDistrict: ${place.subAdministrativeArea}';

        final prefs = await SharedPreferences.getInstance();
        final String? userEmail = prefs.getString('userEmail');

        if (userEmail != null && userEmail.isNotEmpty) {
          final querySnapshot =
              await FirebaseFirestore.instance
                  .collection('victim-info-database')
                  .where('emailAddress', isEqualTo: userEmail)
                  .limit(1)
                  .get();

          if (querySnapshot.docs.isNotEmpty) {
            final docId = querySnapshot.docs.first.id;
            final currentLocation = querySnapshot.docs.first.data()['Location'];

            if (currentLocation == null || currentLocation.toString().isEmpty) {
              await FirebaseFirestore.instance
                  .collection('victim-info-database')
                  .doc(docId)
                  .update({'Location': fullAddress});
            }
          }
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) => OpenStreetMapScreen(
                    latitude: result.latitude,
                    longitude: result.longitude,
                  ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location found but address is unavailable.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppContainers.pageContainer,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryMaroon,
                      width: 8,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.search,
                      size: 80,
                      color: AppColors.primaryMaroon,
                    ),
                  ),
                ),

                const SizedBox(height: 56),

                const Text(
                  'Allow this app to Share my\nLocation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    height: 1.3,
                    color: AppColors.darkCharcoal,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'To send help to your exact location and provide area-specific alerts, we need to access your device\'s location.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: AppButtons.submit,
                    onPressed: _isLoading ? null : _getLocation,
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                            : const Text('Allow Location Access'),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const VictimPage()),
            );
          }
        },
      ),
    );
  }
}
