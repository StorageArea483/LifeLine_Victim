import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Firebase configuration for life-line-admin
const FirebaseOptions _adminFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyCEoP-ISJx1dn1EM7Pt3ikEXlSCkmcpMLY',
  appId: '1:135703361476:web:3a4d9e2ec37c8e3d125691',
  messagingSenderId: '135703361476',
  projectId: 'life-line-admin',
  authDomain: 'life-line-admin.firebaseapp.com',
  storageBucket: 'life-line-admin.firebasestorage.app',
);

// StreamProvider to fetch sos disabled setting from life-line-admin
final sosDisabledStreamProvider = StreamProvider<bool>((ref) async* {
  try {
    // Initialize life-line-admin Firebase app
    FirebaseApp adminApp;
    try {
      adminApp = Firebase.app('life-line-admin');
    } catch (e) {
      adminApp = await Firebase.initializeApp(
        name: 'life-line-admin',
        options: _adminFirebaseOptions,
      );
    }

    final adminFirestore = FirebaseFirestore.instanceFor(app: adminApp);

    // Stream settings collection and extract sos disabled value
    await for (final snapshot
        in adminFirestore.collection('settings').snapshots()) {
      if (snapshot.docs.isNotEmpty) {
        final settingsData = snapshot.docs.first.data();
        final sosDisabled = settingsData['sos disabled'] ?? false;
        yield sosDisabled;
      } else {
        yield false; // Default to false if no settings document exists
      }
    }
  } catch (e) {
    yield false; // Default to false on error
  }
});

// StreamProvider to fetch maintenance setting from life-line-admin
final maintenanceStreamProvider = StreamProvider<bool>((ref) async* {
  try {
    // Initialize life-line-admin Firebase app
    FirebaseApp adminApp;
    try {
      adminApp = Firebase.app('life-line-admin');
    } catch (e) {
      adminApp = await Firebase.initializeApp(
        name: 'life-line-admin',
        options: _adminFirebaseOptions,
      );
    }

    final adminFirestore = FirebaseFirestore.instanceFor(app: adminApp);

    // Stream settings collection and extract maintenance value
    await for (final snapshot
        in adminFirestore.collection('settings').snapshots()) {
      if (snapshot.docs.isNotEmpty) {
        final settingsData = snapshot.docs.first.data();
        final maintenance = settingsData['maintenance'] ?? false;
        yield maintenance;
      } else {
        yield false; // Default to false if no settings document exists
      }
    }
  } catch (e) {
    yield false; // Default to false on error
  }
});
