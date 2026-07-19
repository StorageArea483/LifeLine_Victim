import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Database Credentials Constants
const FirebaseOptions _rescuerAndroidOptions = FirebaseOptions(
  apiKey: 'AIzaSyDs-CoAc_fqrB-3BMl4N7pYSavyNV72zUQ',
  appId: '1:494066243537:android:ffdb36137d6d3cb1a4b2f0',
  messagingSenderId: '494066243537',
  projectId: 'life-line-rescuer-b1f1c',
  storageBucket: 'life-line-rescuer-b1f1c.firebasestorage.app',
);

const FirebaseOptions _rescuerIosOptions = FirebaseOptions(
  apiKey: 'AIzaSyA3cUXkIjLsHhTv2l3OKhNzE3EZtejqxLg',
  appId: '1:494066243537:ios:8f122b25432725a6a4b2f0',
  messagingSenderId: '494066243537',
  projectId: 'life-line-rescuer-b1f1c',
  storageBucket: 'life-line-rescuer-b1f1c.firebasestorage.app',
  iosBundleId: 'com.example.lifeLineRescuer',
);

final rescuerFirestoreProvider = FutureProvider.autoDispose<FirebaseFirestore>((
  ref,
) async {
  FirebaseApp rescuerApp;
  try {
    rescuerApp = Firebase.app('life-line-rescuer');
  } catch (_) {
    rescuerApp = await Firebase.initializeApp(
      name: 'life-line-rescuer',
      options: Platform.isIOS ? _rescuerIosOptions : _rescuerAndroidOptions,
    );
  }
  return FirebaseFirestore.instanceFor(app: rescuerApp);
});
