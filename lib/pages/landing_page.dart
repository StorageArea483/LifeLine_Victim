import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:life_line/services/auth_service.dart';
import 'package:life_line/styles/styles.dart';
import 'package:life_line/widgets/global/bottom_navbar.dart';
import 'package:life_line/widgets/features/maps_module/share_location.dart';
import 'package:life_line/services/google_flood_service.dart';
import 'package:life_line/widgets/fetch_lat_long.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0;
  bool _showEmergencyOptions = false;
  bool _isCheckingFlood = false;

  final GoogleFloodService _floodService = GoogleFloodService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.accentRose,
        title: const Text('LifeLine', style: AppText.appHeader),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              GoogleSignInService.signOut();
            },
          ),
        ],
      ),
      backgroundColor: AppColors.softBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SOS Section
                const SizedBox(height: 10),
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
                                    ? Border.all(
                                      color: AppColors.primaryMaroon,
                                      width: 4,
                                    )
                                    : null,
                          ),
                          child: Center(
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: const Center(
                                child: Text(
                                  'SOS',
                                  style: TextStyle(
                                    fontFamily: 'SFPro',
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
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
                    color: AppColors.surfaceLight,
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
              backgroundColor: AppColors.error,
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
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
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
      final String? uid = FirebaseAuth.instance.currentUser?.uid; // ✅ use uid
      if (uid == null || uid.isEmpty) return;

      await FirebaseFirestore.instance
          .collection('users') // ✅ updated collection name
          .doc(uid) // ✅ direct doc access, no query needed
          .update({'severity': severity});
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
      style: AppButtons.primary.copyWith(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      child:
          isLoading
              ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
              : Text(label, style: AppText.submitButton.copyWith(fontSize: 12)),
    );
  }
}
