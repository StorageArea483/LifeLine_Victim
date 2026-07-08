import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Firebase configuration for life-line-ngo
const FirebaseOptions _ngoFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyBeieryGaw4bh4dtbrI54qsIc51XkP6SoM',
  appId: '1:169949190544:web:2640453ce5dd2aa55d3b15',
  messagingSenderId: '169949190544',
  projectId: 'life-line-ngo',
  authDomain: 'life-line-ngo.firebaseapp.com',
  storageBucket: 'life-line-ngo.firebasestorage.app',
);

final requestExistsStreamProvider = StreamProvider<bool>((ref) async* {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    yield false;
    return;
  }

  // outer stream
  FirebaseApp ngoApp;
  try {
    ngoApp = Firebase.app('life-line-ngo');
  } catch (_) {
    ngoApp = await Firebase.initializeApp(
      name: 'life-line-ngo',
      options: _ngoFirebaseOptions,
    );
  }

  /* The data is passed from inner stream back to outer stream and outer stream updates the UI
     because it is a Stream Provider */
  yield* FirebaseFirestore.instanceFor(
    // inner stream
    app: ngoApp,
  ).collection('requests').doc(user.uid).snapshots().map((snapshot) {
    return snapshot.exists;
  });
});
