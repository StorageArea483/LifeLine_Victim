import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:life_line_victim/providers/rescuer_firebase_provider.dart';

// Keep track of the current active call session ID
final currentCallIdProvider = StateProvider<String?>((ref) => null);

final currentCallDocStreamProvider = StreamProvider<DocumentSnapshot?>((ref) {
  final callId = ref.watch(currentCallIdProvider);
  if (callId == null) return Stream.value(null);

  // Watch the initialization status of your secondary Firestore instance
  final firestoreAsync = ref.watch(rescuerFirestoreProvider);

  return firestoreAsync.maybeWhen(
    data:
        (firestoreValue) =>
            firestoreValue.collection('calls').doc(callId).snapshots(),
    orElse: () => Stream.value(null),
  );
});
