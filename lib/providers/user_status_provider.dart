import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/models/user_status.dart';

final userStatusStreamProvider = StreamProvider.autoDispose<UserStatus?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) {
          FirebaseAuth.instance.signOut();
          return UserStatus(
            isBlocked: false,
            isDeleted: true,
            email: user.email ?? '',
            uid: user.uid,
          );
        }
        final data = snapshot.data()!;
        return UserStatus(
          isBlocked: data['blocked'] ?? false,
          isDeleted: false,
          email: user.email ?? '',
          uid: user.uid,
        );
      });
});
