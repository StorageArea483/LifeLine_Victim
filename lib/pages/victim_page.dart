import 'package:flutter/material.dart';
import 'package:life_line/styles/styles.dart';
import 'package:life_line/widgets/global/bottom_navbar.dart';
import 'package:life_line/widgets/features/maps_module/share_location.dart';
import 'package:life_line/widgets/google_flood_service.dart';
import 'package:life_line/widgets/fetch_lat_long.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VictimPage extends StatefulWidget {
  const VictimPage({super.key});

  @override
  State<VictimPage> createState() => _VictimPageState();
}

class _VictimPageState extends State<VictimPage> {
  int _currentIndex = 0;
  bool _showEmergencyOptions = false;
  bool _isCheckingFlood = false;

  final GoogleFloodService _floodService = GoogleFloodService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48),
                    const Text('Home', style: AppText.appHeader),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.primaryMaroon,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // SOS Section
                Center(
                  child: Column(
                    children: [
                      if (_showEmergencyOptions) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Please select the issue you are facing now',
                            textAlign: TextAlign.center,
                            style: AppText.fieldLabel,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildEmergencyButton('Flood'),
                              const SizedBox(width: 12),
                              _buildEmergencyButton('Accident'),
                              const SizedBox(width: 12),
                              _buildEmergencyButton('Earthquake'),
                            ],
                          ),
                        ),
                      ],

                      // SOS Button with outer ring when tapped
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showEmergencyOptions = !_showEmergencyOptions;
                          });
                        },
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                _showEmergencyOptions
                                    ? Border.all(color: Colors.blue, width: 4)
                                    : null,
                          ),
                          child: Center(
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _showEmergencyOptions
                                        ? AppColors.accentRose
                                        : Colors.red,
                              ),
                              child: const Center(
                                child: Text(
                                  'SOS',
                                  style: TextStyle(
                                    fontFamily: 'SFPro',
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Center(
                  child: Text(
                    'In case of emergency, press the button to alert responders.',
                    textAlign: TextAlign.center,
                    style: AppText.small,
                  ),
                ),

                const SizedBox(height: 40),

                const Text('AI Assistant', style: AppText.fieldLabel),
                const SizedBox(height: 16),

                // Quick First Aid Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.medical_services,
                        color: AppColors.primaryMaroon,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quick First Aid', style: AppText.fieldLabel),
                            Text(
                              'Get instant safety and first aid tips.',
                              style: AppText.small,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                const Text('Recent Notifications', style: AppText.fieldLabel),
                const SizedBox(height: 16),

                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No new notifications', style: AppText.small),
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
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ShareLocation()),
            );
          }
        },
      ),
    );
  }

  Future<void> _handleFloodCheck() async {
    setState(() {
      _isCheckingFlood = true;
    });

    try {
      LocationResult locationResult = await fetchLatLong();

      if (locationResult.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(locationResult.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      FloodData floodData = await _floodService.getFloodRiskForLocation(
        locationResult.latitude,
        locationResult.longitude,
      );

      if (floodData.riskLevel == 'Low Risk' ||
          floodData.riskLevel == 'Medium Risk' ||
          floodData.riskLevel == 'High Risk') {
        await _saveSeverityToDatabase(floodData.riskLevel);
      }

      if (mounted) {
        GoogleFloodService.showFloodRisk(context, floodData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingFlood = false;
        });
      }
    }
  }

  Future<void> _saveSeverityToDatabase(String severity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userEmail = prefs.getString('userEmail');
      if (userEmail == null || userEmail.isEmpty) return;

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('victim-info-database')
              .where('emailAddress', isEqualTo: userEmail)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('victim-info-database')
            .doc(querySnapshot.docs.first.id)
            .update({'severity': severity});
      }
    } catch (e) {
      debugPrint('Error saving severity: $e');
    }
  }

  Widget _buildEmergencyButton(String label) {
    final isLoading = _isCheckingFlood && label == 'Flood';

    return ElevatedButton(
      onPressed:
          _isCheckingFlood
              ? null
              : () async {
                if (label == 'Flood') {
                  await _handleFloodCheck();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label emergency selected'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryMaroon,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child:
          isLoading
              ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : Text(
                label,
                style: const TextStyle(
                  fontFamily: 'SFPro',
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
    );
  }
}
