import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Changed from bool to String? to extract the specific field value
final requestStatusStreamProvider = StreamProvider<String?>((ref) async* {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    yield null;
    return;
  }

  yield* FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data() as Map<String, dynamic>;
          return data['requestAccepted'] as String?;
        }
        return null;
      });
});
