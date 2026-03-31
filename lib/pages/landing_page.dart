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

class _LandingPageState extends ConsumerState<LandingPage>
    with SingleTickerProviderStateMixin {
  final FloodService _floodService = FloodService();
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        title: const Text('LifeLine', style: AppText.appHeader),
        centerTitle: true,
        actions: const [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: GoogleSignInService.signOut,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // SOS Section
              Center(
                child: Column(
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final showEmergencyOptions = ref.watch(
                          landingPageProvider.select(
                            (v) => v.showEmergencyOptions,
                          ),
                        );

                        return Column(
                          children: [
                            if (showEmergencyOptions) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: Text(
                                  'Select Emergency Type',
                                  textAlign: TextAlign.center,
                                  style: AppText.fieldLabel.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    final activeButton = ref.watch(
                                      landingPageProvider.select(
                                        (v) => v.activeButton,
                                      ),
                                    );
                                    return Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      alignment: WrapAlignment.center,
                                      children: [
                                        _buildEmergencyChip(
                                          'Flood',
                                          Icons.water_drop_rounded,
                                          activeButton,
                                        ),
                                        _buildEmergencyChip(
                                          'Accident',
                                          Icons.car_crash_rounded,
                                          activeButton,
                                        ),
                                        _buildEmergencyChip(
                                          'Earthquake',
                                          Icons.landscape_rounded,
                                          activeButton,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],

                            // Animated SOS Button
                            GestureDetector(
                              onTap: () {
                                if (mounted) {
                                  ref
                                      .read(landingPageProvider.notifier)
                                      .setShowEmergencyOptions(
                                        !showEmergencyOptions,
                                      );
                                }
                              },
                              child: AnimatedBuilder(
                                animation:
                                    _pulseAnimation ??
                                    const AlwaysStoppedAnimation(1.0),
                                builder: (context, child) {
                                  return Container(
                                    width: 240,
                                    height: 240,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.error.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 20,
                                          spreadRadius:
                                              showEmergencyOptions ? 5 : 0,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Pulsing ring
                                        if (showEmergencyOptions)
                                          Transform.scale(
                                            scale:
                                                _pulseAnimation?.value ?? 1.0,
                                            child: Container(
                                              width: 220,
                                              height: 220,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.primaryMaroon
                                                      .withOpacity(0.5),
                                                  width: 3,
                                                ),
                                              ),
                                            ),
                                          ),
                                        // Main button
                                        Container(
                                          width: 200,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppColors.error,
                                                AppColors.error.withOpacity(
                                                  0.8,
                                                ),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.error
                                                    .withOpacity(0.4),
                                                blurRadius: 15,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'SOS',
                                              style: TextStyle(
                                                fontFamily: 'SFPro',
                                                fontSize: 56,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.white,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Center(
                child: Text(
                  'In case of emergency, press the button to alert responders.',
                  textAlign: TextAlign.center,
                  style: AppText.small.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // AI Assistant Section
              Text(
                'AI Assistant',
                style: AppText.fieldLabel.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryMaroon.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/robo_head.webp',
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick First Aid',
                            style: AppText.fieldLabel.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Get instant safety and first aid tips.',
                            style: AppText.small.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Recent Notifications Section
              Text(
                'Recent Notifications',
                style: AppText.fieldLabel.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Empty State
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 36,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      size: 40,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "You're all caught up!",
                      style: AppText.fieldLabel.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No new notifications at the moment.',
                      style: AppText.small.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 0),
    );
  }

  Widget _buildEmergencyChip(
    String label,
    IconData icon,
    String? activeButton,
  ) {
    final isThisLoading = activeButton == label;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            activeButton != null
                ? null
                : () async {
                  switch (label) {
                    case 'Flood':
                      await _handleFloodCheck();
                      break;
                    case 'Accident':
                      break;
                    case 'Earthquake':
                      break;
                  }
                },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primaryMaroon.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child:
              isThisLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryMaroon,
                    ),
                  )
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: AppColors.primaryMaroon, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'SFPro',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryMaroon,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Future<void> _handleFloodCheck() async {
    ref.read(landingPageProvider.notifier).setActiveButton('Flood');

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

      if (floodData.errorMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(floodData.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      if (floodData.riskLevel == 'Low Risk' ||
          floodData.riskLevel == 'Medium Risk' ||
          floodData.riskLevel == 'High Risk') {
        await _saveSeverityToDatabase(floodData.riskLevel);
      }

      if (mounted) {
        FloodService.showFloodRisk(context, floodData);
        _showSeverityDialog(floodData.riskLevel);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to process your request, please try again'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) ref.read(landingPageProvider.notifier).clearActiveButton();
    }
  }

  void _showSeverityDialog(String severity) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surfaceLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        severity == 'High Risk'
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    severity == 'High Risk'
                        ? Icons.warning
                        : Icons.info_outline,
                    color:
                        severity == 'High Risk'
                            ? AppColors.error
                            : AppColors.warning,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Flood Risk Detected',
                  style: AppText.formTitle.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Severity level
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        severity == 'High Risk'
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          severity == 'High Risk'
                              ? AppColors.error.withOpacity(0.3)
                              : AppColors.warning.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Severity: $severity',
                    style: TextStyle(
                      fontFamily: 'SFPro',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:
                          severity == 'High Risk'
                              ? AppColors.error
                              : AppColors.warning,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Would you like to discuss your situation with our AI assistant? This helps NGOs better understand your condition and provide appropriate support.',
                  style: AppText.small.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: AppColors.borderColor,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Not Now',
                          style: AppText.button.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chatbot feature coming soon!'),
                              backgroundColor: AppColors.info,
                            ),
                          );
                        },
                        style: AppButtons.primary.copyWith(
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                        child: Text(
                          'Let\'s Discuss',
                          style: AppText.button.copyWith(
                            color: AppColors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
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
}
