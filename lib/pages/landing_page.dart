import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_victim/models/flood_data.dart';
import 'package:life_line_victim/models/earthquake_data.dart';
import 'package:life_line_victim/pages/chat_bot.dart';
import 'package:life_line_victim/pages/google_signup.dart';
import 'package:life_line_victim/pages/ngo_connect.dart';
import 'package:life_line_victim/pages/victim_map_page.dart';
import 'package:life_line_victim/providers/global_address_provider.dart';
import 'package:life_line_victim/providers/landing_page_providers.dart';
import 'package:life_line_victim/providers/lat_lng_provider.dart';
import 'package:life_line_victim/styles/styles.dart';
import 'package:life_line_victim/widgets/global/bottom_navbar.dart';
import 'package:life_line_victim/services/google_flood_service.dart';
import 'package:life_line_victim/services/earthquake_service.dart';
import 'package:life_line_victim/widgets/fetch_lat_long.dart';
import 'package:life_line_victim/services/location_service.dart';
import 'package:life_line_victim/utils/responsive_helper.dart';
import 'package:life_line_victim/widgets/global/in_out_calls.dart';
import 'package:life_line_victim/widgets/global/page_message.dart';
import 'package:life_line_victim/widgets/global/page_navigation.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage>
    with SingleTickerProviderStateMixin {
  final FloodService _floodService = FloodService();
  final EarthquakeService _earthquakeService = EarthquakeService();
  FirebaseFirestore? ngoFirestore;
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  static const FirebaseOptions _ngoFirebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyBeieryGaw4bh4dtbrI54qsIc51XkP6SoM',
    appId: '1:169949190544:web:2640453ce5dd2aa55d3b15',
    messagingSenderId: '169949190544',
    projectId: 'life-line-ngo',
    authDomain: 'life-line-ngo.firebaseapp.com',
    storageBucket: 'life-line-ngo.firebasestorage.app',
  );

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
    _initSecondaryFirebase();
    _checkAssignmentStatus();
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  Future<void> _initSecondaryFirebase() async {
    try {
      FirebaseApp ngoApp;
      // NGO Firebase
      try {
        ngoApp = Firebase.app('life-line-ngo');
      } catch (_) {
        ngoApp = await Firebase.initializeApp(
          name: 'life-line-ngo',
          options: _ngoFirebaseOptions,
        );
      }
      ngoFirestore = FirebaseFirestore.instanceFor(app: ngoApp);
    } catch (e) {
      pageMessage(
        'An unexpected error occurred. Please try again.',
        context,
        AppColors.error,
      );
      pageNavigation(const InOutCalls(child: LandingPage()), context);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
      }

      pageNavigation(const GoogleSignup(), context);
    } catch (e) {
      if (context.mounted) {
        pageMessage(
          'Failed to logout. Please try again.',
          context,
          AppColors.error,
        );
      }
    }
  }

  Future<void> _checkAssignmentStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || ngoFirestore == null) return;

      final requestDoc =
          await ngoFirestore!.collection('requests').doc(user.uid).get();

      if (!requestDoc.exists) return;

      final data = requestDoc.data();
      final assigned = data?['assigned'] as bool? ?? false;

      if (assigned) {
        final lat = (data?['latitude'] as num?)?.toDouble();
        final lng = (data?['longitude'] as num?)?.toDouble();

        if (mounted) {
          ref.read(landingPageProvider.notifier).setRescuerAssigned(true);
          ref.read(landingPageProvider.notifier).setRescuerLocation(lat, lng);
        }
      } else {
        if (mounted) {
          ref.read(landingPageProvider.notifier).setRescuerAssigned(false);
        }
      }
    } catch (e) {
      if (mounted) {
        ref.read(landingPageProvider.notifier).setRescuerAssigned(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        title: Text(
          'LifeLine',
          style: AppText.appHeader.copyWith(
            fontSize: ResponsiveHelper.isTablet(context) ? 24 : 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: AppColors.textSecondary,
              size: ResponsiveHelper.iconSize(context),
            ),
            onPressed: () async {
              await _handleLogout(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: ResponsiveHelper.contentWidth(context),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.horizontalPadding(context),
                  vertical: ResponsiveHelper.verticalPadding(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: ResponsiveHelper.isTablet(context) ? 48 : 32,
                    ),

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
                                      padding: EdgeInsets.only(
                                        bottom:
                                            ResponsiveHelper.isTablet(context)
                                                ? 32
                                                : 24,
                                      ),
                                      child: Text(
                                        'Select Emergency Type',
                                        textAlign: TextAlign.center,
                                        style: AppText.fieldLabel.copyWith(
                                          fontSize:
                                              ResponsiveHelper.isTablet(context)
                                                  ? 20
                                                  : 16,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom:
                                            ResponsiveHelper.isTablet(context)
                                                ? 32
                                                : 24,
                                      ),
                                      child: Consumer(
                                        builder: (context, ref, child) {
                                          final activeButton = ref.watch(
                                            landingPageProvider.select(
                                              (v) => v.activeButton,
                                            ),
                                          );
                                          return Wrap(
                                            spacing:
                                                ResponsiveHelper.isTablet(
                                                      context,
                                                    )
                                                    ? 20
                                                    : 12,
                                            runSpacing:
                                                ResponsiveHelper.isTablet(
                                                      context,
                                                    )
                                                    ? 20
                                                    : 12,
                                            alignment: WrapAlignment.center,
                                            children: [
                                              _buildEmergencyChip(
                                                'Flood',
                                                Icons.water_drop_rounded,
                                                activeButton,
                                              ),
                                              _buildEmergencyChip(
                                                'Medical',
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
                                    onTap: () async {
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
                                          width:
                                              ResponsiveHelper.isTablet(context)
                                                  ? 320
                                                  : 240,
                                          height:
                                              ResponsiveHelper.isTablet(context)
                                                  ? 320
                                                  : 240,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.error
                                                    .withOpacity(0.3),
                                                blurRadius: 20,
                                                spreadRadius:
                                                    showEmergencyOptions
                                                        ? 5
                                                        : 0,
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
                                                      _pulseAnimation?.value ??
                                                      1.0,
                                                  child: Container(
                                                    width:
                                                        ResponsiveHelper.isTablet(
                                                              context,
                                                            )
                                                            ? 290
                                                            : 220,
                                                    height:
                                                        ResponsiveHelper.isTablet(
                                                              context,
                                                            )
                                                            ? 290
                                                            : 220,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: AppColors
                                                            .primaryMaroon
                                                            .withOpacity(0.5),
                                                        width: 3,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              // Main button
                                              Container(
                                                width:
                                                    ResponsiveHelper.isTablet(
                                                          context,
                                                        )
                                                        ? 260
                                                        : 200,
                                                height:
                                                    ResponsiveHelper.isTablet(
                                                          context,
                                                        )
                                                        ? 260
                                                        : 200,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      AppColors.error,
                                                      AppColors.error
                                                          .withOpacity(0.8),
                                                    ],
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.error
                                                          .withOpacity(0.4),
                                                      blurRadius: 15,
                                                      offset: const Offset(
                                                        0,
                                                        5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'SOS',
                                                    style: AppText.sosButton
                                                        .copyWith(
                                                          fontSize:
                                                              ResponsiveHelper.isTablet(
                                                                    context,
                                                                  )
                                                                  ? 64
                                                                  : 48,
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

                    SizedBox(
                      height: ResponsiveHelper.isTablet(context) ? 48 : 32,
                    ),

                    Center(
                      child: Text(
                        'In case of emergency, press the button to alert responders.',
                        textAlign: TextAlign.center,
                        style: AppText.small.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: ResponsiveHelper.bodyFont(context),
                          height: 1.4,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: ResponsiveHelper.isTablet(context) ? 64 : 48,
                    ),

                    // AI Assistant Section
                    Text(
                      'AI Assistant',
                      style: AppText.fieldLabel.copyWith(
                        fontSize: ResponsiveHelper.isTablet(context) ? 22 : 16,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.isTablet(context) ? 24 : 16,
                    ),

                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveHelper.isTablet(context) ? 32 : 20,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
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
                            width: ResponsiveHelper.isTablet(context) ? 80 : 56,
                            height:
                                ResponsiveHelper.isTablet(context) ? 80 : 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryMaroon.withOpacity(
                                    0.3,
                                  ),
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
                                  width:
                                      ResponsiveHelper.isTablet(context)
                                          ? 80
                                          : 56,
                                  height:
                                      ResponsiveHelper.isTablet(context)
                                          ? 80
                                          : 56,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: ResponsiveHelper.isTablet(context) ? 24 : 16,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quick First Aid',
                                  style: AppText.fieldLabel.copyWith(
                                    fontSize:
                                        ResponsiveHelper.isTablet(context)
                                            ? 18
                                            : 15,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                TextButton(
                                  onPressed: () {
                                    pageNavigation(
                                      const InOutCalls(
                                        child: ChatBot(request: 'medical'),
                                      ),
                                      context,
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Get instant safety and first aid tips.',
                                          style: AppText.small.copyWith(
                                            color: AppColors.textSecondary,
                                            fontSize: ResponsiveHelper.bodyFont(
                                              context,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: AppColors.textSecondary,
                                        size:
                                            ResponsiveHelper.isTablet(context)
                                                ? 32
                                                : 25,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Consumer(
                      builder: (context, ref, child) {
                        final rescuerAssigned = ref.watch(
                          landingPageProvider.select((v) => v.rescuerAssigned),
                        );
                        final rescuerLatitude = ref.watch(
                          landingPageProvider.select((v) => v.rescuerLatitude),
                        );
                        final rescuerLongitude = ref.watch(
                          landingPageProvider.select((v) => v.rescuerLongitude),
                        );

                        if (!rescuerAssigned) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height:
                                  ResponsiveHelper.isTablet(context) ? 24 : 16,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.borderColor,
                                  width: 1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.shadowLight,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal:
                                      ResponsiveHelper.isTablet(context)
                                          ? 24
                                          : 16,
                                  vertical: 8,
                                ),
                                title: Text(
                                  'Show Rescuer Live Location',
                                  style: AppText.fieldLabel.copyWith(
                                    fontSize:
                                        ResponsiveHelper.isTablet(context)
                                            ? 18
                                            : 15,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.location_on,
                                    color: AppColors.primaryMaroon,
                                    size: 25,
                                  ),
                                  onPressed: () {
                                    pageNavigation(
                                      InOutCalls(
                                        child: VictimMapPage(
                                          rescuerLatitude: rescuerLatitude,
                                          rescuerLongitude: rescuerLongitude,
                                        ),
                                      ),
                                      context,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
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
                      await _handleFloodCheck(label);
                      break;
                    case 'Medical':
                      await _handleMedicalCheck(label);
                      break;
                    case 'Earthquake':
                      await _handleEarthquakeCheck(label);
                      break;
                  }
                },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.isTablet(context) ? 32 : 20,
            vertical: ResponsiveHelper.isTablet(context) ? 16 : 12,
          ),
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
                  ? SizedBox(
                    width: ResponsiveHelper.isTablet(context) ? 20 : 16,
                    height: ResponsiveHelper.isTablet(context) ? 20 : 16,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryMaroon,
                    ),
                  )
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        color: AppColors.primaryMaroon,
                        size: ResponsiveHelper.isTablet(context) ? 24 : 18,
                      ),
                      SizedBox(
                        width: ResponsiveHelper.isTablet(context) ? 12 : 8,
                      ),
                      Text(
                        label,
                        style: AppText.small.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryMaroon,
                          fontSize: ResponsiveHelper.bodyFont(context),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Future<void> _handleFloodCheck(String label) async {
    if (mounted) {
      ref.read(landingPageProvider.notifier).setActiveButton(label);
    }

    try {
      final locationResult = await fetchLatLong();
      if (locationResult.error != null) {
        if (mounted) {
          pageMessage(locationResult.error!, context, AppColors.error);
        }
        return;
      }

      final FloodData floodData = await _floodService.getFloodRiskForLocation(
        locationResult.latitude,
        locationResult.longitude,
      );

      if (floodData.errorMessage != null) {
        pageMessage(floodData.errorMessage!, context, AppColors.error);
        return;
      }

      // Update location in users collection
      await LocationService.updateUserLocation(
        locationResult.address,
        floodData.rainMm.toString(),
      );

      if (mounted) {
        ref.read(latLngProvider.notifier).setLatitude(locationResult.latitude);
        ref
            .read(latLngProvider.notifier)
            .setLongitude(locationResult.longitude);
        ref.read(globalAddressProvider.notifier).state = locationResult.address;
      }

      if (mounted) {
        _showSeverityDialog(
          floodData.riskLevel,
          label,
          intensity: floodData.rainMm,
        );
      }
    } catch (e) {
      pageMessage(
        'Unable to process your request, please try again',
        context,
        AppColors.error,
      );
    } finally {
      if (mounted) {
        ref.read(landingPageProvider.notifier).clearActiveButton();
      }
    }
  }

  Future<void> _handleMedicalCheck(String label) async {
    if (mounted) {
      ref.read(landingPageProvider.notifier).setActiveButton(label);
    }
    try {
      final locationResult = await fetchLatLong();
      if (locationResult.error != null) {
        if (mounted) {
          pageMessage(locationResult.error!, context, AppColors.error);
        }
        return;
      }
      // Update location in users collection
      await LocationService.updateUserLocation(locationResult.address, null);

      if (mounted) {
        ref.read(latLngProvider.notifier).setLatitude(locationResult.latitude);
        ref
            .read(latLngProvider.notifier)
            .setLongitude(locationResult.longitude);
        ref.read(globalAddressProvider.notifier).state = locationResult.address;
      }
      // Show NGO connection sheet
      if (mounted) {
        NgoConnectSheet.show(context, requestType: label, severity: 'Urgent');
      }
    } catch (e) {
      pageMessage(
        'Unable to process your request, please try again',
        context,
        AppColors.error,
      );
    } finally {
      if (mounted) {
        ref.read(landingPageProvider.notifier).clearActiveButton();
      }
    }
  }

  Future<void> _handleEarthquakeCheck(String label) async {
    if (mounted) {
      ref.read(landingPageProvider.notifier).setActiveButton(label);
    }

    try {
      final locationResult = await fetchLatLong();
      if (locationResult.error != null) {
        pageMessage(locationResult.error!, context, AppColors.error);
        return;
      }

      final EarthquakeData earthquakeData = await _earthquakeService
          .getEarthquakeRiskForLocation(
            locationResult.latitude,
            locationResult.longitude,
          );

      if (earthquakeData.errorMessage != null) {
        pageMessage(earthquakeData.errorMessage!, context, AppColors.error);
        return;
      }

      // Update location in users collection
      await LocationService.updateUserLocation(
        locationResult.address,
        earthquakeData.riskLevel,
      );
      if (mounted) {
        ref.read(latLngProvider.notifier).setLatitude(locationResult.latitude);
        ref
            .read(latLngProvider.notifier)
            .setLongitude(locationResult.longitude);
        ref.read(globalAddressProvider.notifier).state = locationResult.address;
      }

      if (mounted) {
        _showSeverityDialog(
          earthquakeData.riskLevel,
          label,
          magnitude: earthquakeData.magnitude,
        );
      }
    } catch (e) {
      pageMessage(
        'Unable to process your request, please try again',
        context,
        AppColors.error,
      );
    } finally {
      if (mounted) {
        ref.read(landingPageProvider.notifier).clearActiveButton();
      }
    }
  }

  void _showSeverityDialog(
    String severity,
    String label, {
    double? magnitude,
    double? intensity,
  }) {
    final bool isLowRisk = severity == 'Low Risk';

    final String title =
        isLowRisk
            ? (label == 'Flood'
                ? 'No Flood Risk Detected'
                : 'No Earthquake Risk Detected')
            : (label == 'Flood'
                ? 'Flood Risk Detected'
                : 'Earthquake Risk Detected');

    final IconData icon =
        severity == 'High Risk'
            ? Icons.warning
            : (isLowRisk ? Icons.check_circle : Icons.info_outline);

    final Color iconColor =
        severity == 'High Risk'
            ? AppColors.error
            : (isLowRisk ? AppColors.success : AppColors.warning);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surfaceLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: EdgeInsets.zero,
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      ResponsiveHelper.isTablet(context)
                          ? 650
                          : double.infinity,
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.isTablet(context) ? 32 : 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        padding: EdgeInsets.all(
                          ResponsiveHelper.isTablet(context) ? 24 : 16,
                        ),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: ResponsiveHelper.isTablet(context) ? 64 : 48,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 28 : 20,
                      ),

                      // Title
                      Text(
                        title,
                        style: AppText.formTitle.copyWith(
                          fontSize: ResponsiveHelper.titleFont(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 16 : 12,
                      ),

                      // Severity level
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              ResponsiveHelper.isTablet(context) ? 20 : 16,
                          vertical: ResponsiveHelper.isTablet(context) ? 12 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: iconColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Severity: $severity',
                          style: AppText.small.copyWith(
                            fontWeight: FontWeight.w600,
                            color: iconColor,
                            fontSize: ResponsiveHelper.bodyFont(context),
                          ),
                        ),
                      ),

                      // Show magnitude or intensity if available
                      if (magnitude != null || intensity != null) ...[
                        SizedBox(
                          height: ResponsiveHelper.isTablet(context) ? 16 : 12,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveHelper.isTablet(context) ? 20 : 16,
                            vertical:
                                ResponsiveHelper.isTablet(context) ? 12 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.textSecondary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            magnitude != null
                                ? 'Magnitude: ${magnitude.toStringAsFixed(1)}'
                                : 'Rain Intensity: ${intensity!.toStringAsFixed(1)}',
                            style: AppText.small.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              fontSize: ResponsiveHelper.bodyFont(context),
                            ),
                          ),
                        ),
                      ],

                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 24 : 16,
                      ),

                      // Description
                      Text(
                        'Would you like to discuss your situation with our AI assistant? This helps NGOs better understand your condition and provide appropriate support.',
                        style: AppText.small.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                          fontSize: ResponsiveHelper.bodyFont(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 32 : 24,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                if (mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical:
                                      ResponsiveHelper.isTablet(context)
                                          ? 18
                                          : 14,
                                ),
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
                                  fontSize: ResponsiveHelper.bodyFont(context),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: ResponsiveHelper.isTablet(context) ? 16 : 12,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (!mounted) return;
                                Navigator.of(context).pop();
                                pageNavigation(
                                  InOutCalls(
                                    child: ChatBot(
                                      request: label,
                                      severity: severity,
                                    ),
                                  ),
                                  context,
                                );
                              },
                              style: AppButtons.primary.copyWith(
                                padding: WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(
                                    vertical:
                                        ResponsiveHelper.isTablet(context)
                                            ? 18
                                            : 14,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Let\'s Discuss',
                                style: AppText.button.copyWith(
                                  color: AppColors.white,
                                  fontSize: ResponsiveHelper.bodyFont(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
