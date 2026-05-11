import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/models/user_status.dart';

final userStatusStreamProvider = StreamProvider<UserStatus?>((ref) async* {
  try {
    // Get current authenticated user
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      yield null;
      return;
    }
    await for (final snapshot
        in FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()) {
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        final isBlocked = userData['blocked'] ?? false;
        yield UserStatus(
          isBlocked: isBlocked,
          isDeleted: false,
          email: user.email ?? '',
          uid: user.uid,
        );
      } else {
        await FirebaseAuth.instance.signOut();
        yield UserStatus(
          isBlocked: false,
          isDeleted: true,
          email: user.email ?? '',
          uid: user.uid,
        );
      }
    }
  } catch (e) {
    // On error, treat as not blocked/deleted to avoid blocking legitimate users
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      yield UserStatus(
        isBlocked: false,
        isDeleted: false,
        email: user.email ?? '',
        uid: user.uid,
      );
    } else {
      yield null;
    }
  }
});
