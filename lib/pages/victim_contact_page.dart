import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_victim/pages/landing_page.dart';
import 'package:life_line_victim/styles/styles.dart';
import 'dart:io' show Platform;

import 'package:life_line_victim/widgets/global/page_message.dart';
import 'package:life_line_victim/widgets/global/page_navigation.dart';

class VictimContactPage extends ConsumerStatefulWidget {
  const VictimContactPage({super.key});

  @override
  ConsumerState<VictimContactPage> createState() => _VictimContactPageState();
}

class _VictimContactPageState extends ConsumerState<VictimContactPage> {
  FirebaseFirestore? rescuerFirestore;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSecondaryFirebase();
    });
  }

  Future<void> _initSecondaryFirebase() async {
    FirebaseApp rescuerApp;

    try {
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
    } catch (e) {
      pageMessage(
        'An unexpected error occurred. Please try again.',
        context,
        AppColors.error,
      );
      pageNavigation(const LandingPage(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Victim Contact Page')));
  }
}
