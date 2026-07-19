import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_victim/pages/landing_page.dart';
import 'package:life_line_victim/providers/victim_contact_provider.dart';
import 'package:life_line_victim/services/call_service.dart';
import 'package:life_line_victim/styles/styles.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:life_line_victim/utils/responsive_helper.dart';
import 'package:life_line_victim/widgets/global/bottom_navbar.dart';
import 'package:life_line_victim/widgets/global/in_out_calls.dart';
import 'package:life_line_victim/widgets/global/ngo_chat_screen.dart';
import 'package:life_line_victim/widgets/global/page_loading.dart';
import 'package:life_line_victim/widgets/global/page_message.dart';
import 'package:life_line_victim/widgets/global/page_navigation.dart';
import 'package:life_line_victim/widgets/global/victim_chat_screen.dart';

class VictimContactPage extends ConsumerStatefulWidget {
  const VictimContactPage({super.key});

  @override
  ConsumerState<VictimContactPage> createState() => _VictimContactPageState();
}

class _VictimContactPageState extends ConsumerState<VictimContactPage>
    with WidgetsBindingObserver {
  FirebaseFirestore? rescuerFirestore;
  FirebaseFirestore? ngoFirestore;

  // life-line-rescuer database credentials
  static const FirebaseOptions _rescuerAndroidOptions = FirebaseOptions(
    apiKey: 'AIzaSyDs-CoAc_fqrB-3BMl4N7pYSavyNV72zUQ',
    appId: '1:494066243537:android:ffdb36137d6d3cb1a4b2f0',
    messagingSenderId: '494066243537',
    projectId: 'life-line-rescuer-b1f1c',
    storageBucket: 'life-line-rescuer-b1f1c.firebasestorage.app',
  );

  static const FirebaseOptions _rescuerIosOptions = FirebaseOptions(
    apiKey: 'AIzaSyA3cUXkIjLsHhTv2l3OKhNzE3EZtejqxLg',
    appId: '1:494066243537:ios:8f122b25432725a6a4b2f0',
    messagingSenderId: '494066243537',
    projectId: 'life-line-rescuer-b1f1c',
    storageBucket: 'life-line-rescuer-b1f1c.firebasestorage.app',
    iosBundleId: 'com.example.lifeLineRescuer',
  );

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
    WidgetsBinding.instance.addObserver(this);
    _updateOnlineStatus(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSecondaryFirebase();
    });
  }

  @override
  void dispose() {
    _updateOnlineStatus(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateOnlineStatus(true);
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _updateOnlineStatus(false);
    }
  }

  Future<void> _updateOnlineStatus(bool online) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'online': online},
      );
    } catch (_) {}
  }

  Future<void> _initSecondaryFirebase() async {
    if (mounted) {
      ref.read(victimContactLoadingProvider.notifier).state = true;
    }
    try {
      FirebaseApp rescuerApp;
      FirebaseApp ngoApp;

      // Rescuer Firebase
      try {
        rescuerApp = Firebase.app('life-line-rescuer');
      } catch (_) {
        rescuerApp = await Firebase.initializeApp(
          name: 'life-line-rescuer',
          options: Platform.isIOS ? _rescuerIosOptions : _rescuerAndroidOptions,
        );
      }
      rescuerFirestore = FirebaseFirestore.instanceFor(app: rescuerApp);

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

      await _fetchAssignedRescuer();
      await _fetchAssignedNgo();

      if (mounted) {
        ref.read(victimContactLoadingProvider.notifier).state = false;
      }
    } catch (e) {
      if (mounted) {
        ref.read(victimContactLoadingProvider.notifier).state = false;
        pageMessage(
          'An unexpected error occurred. Please try again.',
          context,
          AppColors.error,
        );
        pageNavigation(const InOutCalls(child: LandingPage()), context);
      }
    }
  }

  Future<void> _fetchAssignedRescuer() async {
    if (rescuerFirestore == null) return;
    try {
      final victimId = FirebaseAuth.instance.currentUser?.uid;
      if (victimId == null) return;

      final victimDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(victimId)
              .get();
      if (!victimDoc.exists) return;

      final dataMap = victimDoc.data();
      if (dataMap == null) return;

      // 1. Check if requestAccepted is equal to "accepted"
      final requestAcceptedStatus = dataMap['requestAccepted'];
      if (requestAcceptedStatus != 'accepted') return;

      // 2. Extract and check the assignedWith key
      final rescuerId = dataMap['assignedWith'];
      if (rescuerId == null || rescuerId.toString().isEmpty) return;

      final rescuerDoc =
          await rescuerFirestore!.collection('users').doc(rescuerId).get();
      if (!rescuerDoc.exists) return;

      final data = rescuerDoc.data()!;
      final firstName = data['firstName'] ?? '';
      final lastName = data['lastName'] ?? '';
      final fullName = '$firstName $lastName'.trim();

      if (mounted) {
        ref.read(assignedRescuerProvider.notifier).state = {
          'id': rescuerDoc.id,
          'fullName': fullName.isEmpty ? 'N/A' : fullName,
          'photoURL': data['photoURL'] ?? '',
          'online': data['online'] ?? false,
        };
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _fetchAssignedNgo() async {
    if (ngoFirestore == null) return;
    try {
      final victimId = FirebaseAuth.instance.currentUser?.uid;
      if (victimId == null) return;

      final requestDoc =
          await ngoFirestore!.collection('requests').doc(victimId).get();
      if (!requestDoc.exists) return;

      final ngoId = requestDoc.data()?['ngoId'];
      if (ngoId == null || ngoId.toString().isEmpty) return;

      final ngoDoc =
          await ngoFirestore!.collection('ngo-info-database').doc(ngoId).get();
      if (!ngoDoc.exists) return;

      final data = ngoDoc.data()!;

      if (mounted) {
        ref.read(assignedNgoProvider.notifier).state = {
          'id': ngoId,
          'ngoName': data['ngoName'] ?? 'Unknown NGO',
          'geographicalCoverage': data['geographicalCoverage'] ?? 'N/A',
        };
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Clean, direct layout tree setup matching the Rescuer configuration
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        iconTheme: IconThemeData(
          size: ResponsiveHelper.iconSize(context),
          color: AppColors.textPrimary,
        ),
        title: Text(
          'Contacts',
          style: AppText.appHeader.copyWith(
            fontSize: ResponsiveHelper.isTablet(context) ? 24 : 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: ResponsiveHelper.contentWidth(context),
            child: Consumer(
              builder: (context, ref, child) {
                return _buildBody(ref);
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 3),
    );
  }

  Widget _buildBody(WidgetRef ref) {
    final isLoading = ref.watch(victimContactLoadingProvider);
    final rescuer = ref.watch(assignedRescuerProvider);
    final ngo = ref.watch(assignedNgoProvider);

    if (isLoading) {
      return pageLoading(context);
    }

    if (rescuer == null && ngo == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.isTablet(context) ? 48 : 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_search_outlined,
                color: AppColors.textSecondary.withOpacity(0.5),
                size: ResponsiveHelper.isTablet(context) ? 96 : 64,
              ),
              SizedBox(height: ResponsiveHelper.isTablet(context) ? 24 : 16),
              Text(
                'No contacts assigned yet',
                style: AppText.subtitle.copyWith(
                  fontSize: ResponsiveHelper.titleFont(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(ResponsiveHelper.isTablet(context) ? 32 : 16),
      children: [
        if (rescuer != null) _buildRescuerCard(rescuer),
        if (ngo != null) _buildNgoCard(ngo),
      ],
    );
  }

  Widget _buildRescuerCard(Map<String, dynamic> rescuer) {
    final fullName = rescuer['fullName'] ?? 'N/A';
    final photoURL = rescuer['photoURL'] ?? '';
    final bool isOnline = rescuer['online'] ?? false;
    final avatarSize = ResponsiveHelper.isTablet(context) ? 72.0 : 48.0;

    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.isTablet(context) ? 24 : 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryMaroon.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkCharcoal.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          pageNavigation(
            InOutCalls(
              child: VictimChatScreen(
                rescuerId: rescuer['id'],
                rescuerName: fullName,
                rescuerPhotoUrl: photoURL,
              ),
            ),
            context,
          );
        },
        contentPadding: EdgeInsets.all(
          ResponsiveHelper.isTablet(context) ? 24 : 16,
        ),
        leading: SizedBox(
          width: avatarSize,
          height: avatarSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: AppColors.primaryMaroon.withOpacity(0.1),
                backgroundImage:
                    photoURL.isNotEmpty ? NetworkImage(photoURL) : null,
                child:
                    photoURL.isEmpty
                        ? Icon(
                          Icons.person,
                          color: AppColors.primaryMaroon,
                          size: avatarSize * 0.5,
                        )
                        : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: avatarSize * 0.28,
                  height: avatarSize * 0.28,
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surfaceLight, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          fullName,
          style: AppText.fieldLabel.copyWith(
            fontSize: ResponsiveHelper.isTablet(context) ? 20 : 16,
            fontWeight: FontWeight.w700,
            color: AppColors.darkCharcoal,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            isOnline ? 'Online' : 'Offline',
            style: AppText.small.copyWith(
              color: AppColors.textSecondary,
              fontSize: ResponsiveHelper.bodyFont(context),
            ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.call,
            color: AppColors.primaryMaroon,
            size: ResponsiveHelper.iconSize(context),
          ),
          onPressed: () async {
            final victimId = FirebaseAuth.instance.currentUser?.uid;
            if (victimId == null || rescuerFirestore == null) return;
            await CallService.initiateCall(
              callerId: victimId,
              receiverId: rescuer['id'] ?? '',
              callerName:
                  FirebaseAuth.instance.currentUser?.displayName ?? 'Victim',
              callerPhotoUrl: FirebaseAuth.instance.currentUser?.photoURL ?? '',
              rescuerFirestore: rescuerFirestore!,
              audioOnly: false,
            );
          },
        ),
      ),
    );
  }

  Widget _buildNgoCard(Map<String, dynamic> ngo) {
    final ngoName = ngo['ngoName'] ?? 'Unknown NGO';
    final geographicalCoverage = ngo['geographicalCoverage'] ?? 'N/A';

    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.isTablet(context) ? 24 : 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryMaroon.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkCharcoal.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          pageNavigation(
            InOutCalls(
              child: NgoChatScreen(ngoId: ngo['ngoId'] ?? '', ngoName: ngoName),
            ),
            context,
          );
        },
        child: ListTile(
          contentPadding: EdgeInsets.all(
            ResponsiveHelper.isTablet(context) ? 24 : 16,
          ),
          leading: _buildNgoLogo(ngoName),
          title: Text(
            ngoName,
            style: AppText.fieldLabel.copyWith(
              fontSize: ResponsiveHelper.isTablet(context) ? 20 : 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkCharcoal,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              geographicalCoverage,
              style: AppText.small.copyWith(
                color: AppColors.textSecondary,
                fontSize: ResponsiveHelper.bodyFont(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNgoLogo(String ngoName) {
    return Container(
      width: ResponsiveHelper.isTablet(context) ? 72 : 48,
      height: ResponsiveHelper.isTablet(context) ? 72 : 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/offline_logos/$ngoName.webp',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.primaryMaroon.withOpacity(0.1),
              child: Icon(
                Icons.business,
                color: AppColors.primaryMaroon,
                size: ResponsiveHelper.isTablet(context) ? 36 : 24,
              ),
            );
          },
        ),
      ),
    );
  }
}
