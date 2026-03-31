import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/models/flood_data.dart';
import 'package:life_line/providers/landing_page_providers.dart';
import 'package:life_line/services/auth_service.dart';
import 'package:life_line/styles/styles.dart';
import 'package:life_line/widgets/global/bottom_navbar.dart';
import 'package:life_line/services/google_flood_service.dart';
import 'package:life_line/widgets/fetch_lat_long.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  final FloodService _floodService = FloodService(); // ✅ fixed class name

  @override
  Widget build(BuildContext context) {
    // ✅ Watch both values at top of build — clean and reactive
    final showEmergencyOptions = ref.watch(
      landingPageProvider.select((v) => v.showEmergencyOptions),
    );
    final isLoading = ref.watch(landingPageProvider.select((v) => v.isLoading));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.accentRose,
        title: const Text('LifeLine', style: AppText.appHeader),
        centerTitle: true,
        actions: const [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: GoogleSignInService.signOut,
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
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      // ✅ No Consumer needed — parent already watches state
                      if (showEmergencyOptions) ...[
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
                              _buildEmergencyButton('Flood', isLoading),
                              const SizedBox(width: 12),
                              _buildEmergencyButton('Accident', isLoading),
                              const SizedBox(width: 12),
                              _buildEmergencyButton('Earthquake', isLoading),
                            ],
                          ),
                        ),
                      ],

                      // SOS Button
                      GestureDetector(
                        onTap: () {
                          // ✅ No mounted check needed for ref.read
                          ref
                              .read(landingPageProvider.notifier)
                              .setShowEmergencyOptions(!showEmergencyOptions);
                        },
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                showEmergencyOptions
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
      bottomNavigationBar: const BottomNavbar(currentIndex: 0),
    );
  }

  Future<void> _handleFloodCheck() async {
    // ✅ Set isLoading = true BEFORE starting work
    ref.read(landingPageProvider.notifier).setLoading(true);

    try {
      final locationResult = await fetchLatLong();

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

      final FloodData floodData = await _floodService.getFloodRiskForLocation(
        locationResult.latitude,
        locationResult.longitude,
      );

      if (floodData.riskLevel == 'Low Risk' ||
          floodData.riskLevel == 'Medium Risk' ||
          floodData.riskLevel == 'High Risk') {
        await _saveSeverityToDatabase(floodData.riskLevel);
      }

      if (mounted) {
        FloodService.showFloodRisk(context, floodData);
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
      // ✅ Always reset loading when done (success or error)
      if (mounted) {
        ref.read(landingPageProvider.notifier).setLoading(false);
      }
    }
  }

  Future<void> _saveSeverityToDatabase(String severity) async {
    try {
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || uid.isEmpty) return;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'severity': severity,
      });
    } catch (e) {
      debugPrint('Error saving severity: $e');
    }
  }

  // ✅ isLoading passed as parameter — only Flood button shows spinner
  Widget _buildEmergencyButton(String label, bool isLoading) {
    final isFloodLoading = isLoading && label == 'Flood';

    return ElevatedButton(
      onPressed:
          isFloodLoading
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
          isFloodLoading
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
