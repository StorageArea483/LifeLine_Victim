import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_victim/pages/google_signup.dart';
import 'package:life_line_victim/pages/landing_page.dart';
import 'package:life_line_victim/pages/maintenance_page.dart';
import 'package:life_line_victim/pages/offline_connectivity.dart';
import 'package:life_line_victim/pages/sos_alternative.dart';
import 'package:life_line_victim/pages/victim_waiting_screen.dart';
import 'package:life_line_victim/providers/app_router_provider.dart';
import 'package:life_line_victim/styles/styles.dart';
import 'package:life_line_victim/pages/victim_blocked_dialog.dart';
import 'package:life_line_victim/widgets/global/page_message.dart';

class CheckConnection extends ConsumerStatefulWidget {
  const CheckConnection({super.key});

  @override
  ConsumerState<CheckConnection> createState() => _CheckConnectionState();
}

class _CheckConnectionState extends ConsumerState<CheckConnection>
    with WidgetsBindingObserver {
  FirebaseFirestore? _ngoFirestore;

  // Firebase configuration for life-line-ngo
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
    _initSecondaryFirebase();
  }

  @override
  void dispose() {
    _updateOnlineStatus(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initSecondaryFirebase() async {
    try {
      FirebaseApp ngoApp;
      try {
        ngoApp = Firebase.app('life-line-ngo');
      } catch (_) {
        ngoApp = await Firebase.initializeApp(
          name: 'life-line-ngo',
          options: _ngoFirebaseOptions,
        );
      }
      _ngoFirestore = FirebaseFirestore.instanceFor(app: ngoApp);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc =
          await _ngoFirestore!.collection('requests').doc(user.uid).get();
      if (!doc.exists) return;
      final data = doc.data();
      final fetchedType = data?['requestType'] as String?;
      if (mounted && fetchedType != null) {
        ref.read(requestTypeProvider.notifier).state = fetchedType;
      }
    } catch (e) {
      pageMessage(
        'An unexpected error occurred please retry',
        context,
        AppColors.error,
      );
    }
  }

  Future<void> _updateOnlineStatus(bool online) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'online': online},
      );
    } catch (e) {
      // ignore errors
    }
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

  @override
  Widget build(BuildContext context) {
    final route = ref.watch(appRouterProvider);

    switch (route) {
      case AppRoute.loading:
        return _loadingScreen();

      case AppRoute.offline:
        return const OfflineConnectivity();

      case AppRoute.login:
        return const GoogleSignup();

      case AppRoute.maintenance:
        return const MaintenancePage();

      case AppRoute.sosDisabled:
        return const SosAlternative();

      case AppRoute.victimWaiting:
        return Consumer(
          builder: (context, ref, child) {
            final requestType = ref.watch(requestTypeProvider);
            return VictimWaitingScreen(requestType: requestType);
          },
        );

      case AppRoute.home:
        return const LandingPage();

      case AppRoute.blocked:
        final user = FirebaseAuth.instance.currentUser;
        return VictimBlockedDialog(email: user?.email ?? '');
    }
  }

  Widget _loadingScreen() {
    return Scaffold(
      body: Container(
        decoration: AppContainers.pageContainer,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryMaroon),
        ),
      ),
    );
  }
}
