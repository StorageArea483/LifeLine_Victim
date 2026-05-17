import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/models/admin_settings.dart';

// Firebase configuration for life-line-admin
const FirebaseOptions _adminFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyCEoP-ISJx1dn1EM7Pt3ikEXlSCkmcpMLY',
  appId: '1:135703361476:web:3a4d9e2ec37c8e3d125691',
  messagingSenderId: '135703361476',
  projectId: 'life-line-admin',
  authDomain: 'life-line-admin.firebaseapp.com',
  storageBucket: 'life-line-admin.firebasestorage.app',
);

final adminSettingsStreamProvider = StreamProvider<AdminSettings>((ref) async* {
  // outer stream
  FirebaseApp adminApp;
  try {
    adminApp = Firebase.app('life-line-admin');
  } catch (_) {
    adminApp = await Firebase.initializeApp(
      name: 'life-line-admin',
      options: _adminFirebaseOptions,
    );
  }
  /* The data is passed from inner stream back to outer stream and outer stream updates the UI 
    because it is a Stream Provider */
  yield* FirebaseFirestore.instanceFor(
    // inner stream
    app: adminApp,
  ).collection('settings').snapshots().map((snapshot) {
    if (snapshot.docs.isEmpty) {
      return const AdminSettings(sosDisabled: false, maintenance: false);
    }
    final data = snapshot.docs.first.data();
    return AdminSettings(
      sosDisabled: data['sos disabled'] ?? false,
      maintenance: data['maintenance'] ?? false,
    );
  });
});
