import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:life_line_victim/providers/rescuer_firebase_provider.dart';

// Keep track of the active call ID
final activeCallIdProvider = StateProvider<String?>((ref) => null);

// Stream incoming calls from the secondary Firestore instance
final incomingCallStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value(null);
  }

  // Watch the initialization status of the secondary database
  final firestoreAsync = ref.watch(rescuerFirestoreProvider);

  return firestoreAsync.maybeWhen(
    data: (firestoreInstance) {
      return firestoreInstance
          .collection('calls')
          .where('receiverId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'ringing')
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isEmpty) {
              return null;
            }

            // Capture the most recent ringing call
            final doc = snapshot.docs.first;
            final data = doc.data();

            return {
              'callId': doc.id,
              'senderId': data['senderId'] ?? '',
              'receiverId': data['receiverId'] ?? '',
              'callerName': data['callerName'] ?? 'Unknown',
              'callerPhotoUrl': data['callerPhotoUrl'] ?? '',
              'audioOnly': data['audioOnly'] ?? false,
            };
          });
    },
    // Return empty stream while the secondary Firebase is spinning up
    orElse: () => Stream.value(null),
  );
});
