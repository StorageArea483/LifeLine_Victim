import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_line_victim/providers/call_state_provider.dart';
import 'package:life_line_victim/services/call_service.dart';
import 'package:life_line_victim/styles/styles.dart';

class OutgoingCallScreen extends ConsumerWidget {
  final String callId;
  final String receiverName;
  final FirebaseFirestore rescuerFirestore;

  const OutgoingCallScreen({
    super.key,
    required this.callId,
    required this.receiverName,
    required this.rescuerFirestore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.primaryMaroon,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              "Calling...",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              receiverName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.red,
              child: IconButton(
                icon: const Icon(Icons.call_end, color: Colors.white, size: 30),
                onPressed: () async {
                  // Completely deletes document & cancels Jitsi setup
                  await CallService.cancelCall(
                    callId,
                    rescuerFirestore: rescuerFirestore,
                  );
                  if (!context.mounted) return;
                  ref.read(currentCallIdProvider.notifier).state = null;
                },
              ),
            ),
            const SizedBox(height: 8),
            const Text("Cancel", style: TextStyle(color: Colors.white)),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
