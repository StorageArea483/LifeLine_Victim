import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_victim/providers/incoming_call_provider.dart';
import 'package:life_line_victim/services/call_service.dart';
import 'package:life_line_victim/styles/styles.dart';
import 'dart:io' show Platform;

class IncomingCallScreen extends ConsumerStatefulWidget {
  const IncomingCallScreen({super.key});

  @override
  ConsumerState<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends ConsumerState<IncomingCallScreen> {
  FirebaseFirestore? rescuerFirestore;

  // life-line-rescuer database credentials
  static const FirebaseOptions _rescuerAndroidOptions = FirebaseOptions(
    apiKey: 'AIzaSyDs-CoAc_fqrB-3BMl4N7pYSavyNV72zUQ',
    appId: '1:494066243537:android:ffdb36137d6d3cb1a4b2f0',
    messagingSenderId: '494066243537',
    projectId: 'life-line-rescuer-b1f1c',
    storageBucket: 'life-line-rescuer-b1f1c.firebasestorage.app',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSecondaryFirebase();
    });
  }

  Future<void> _initSecondaryFirebase() async {
    try {
      FirebaseApp rescuerApp;
      // Rescuer Firebase
      try {
        rescuerApp = Firebase.app('life-line-rescuer');
      } catch (_) {
        rescuerApp = await Firebase.initializeApp(
          name: 'life-line-rescuer',
          options: Platform.isIOS ? _rescuerIosOptions : _rescuerAndroidOptions,
        );
      }

      rescuerFirestore = FirebaseFirestore.instanceFor(app: rescuerApp);
    } catch (e) {
      // ignore firebase errors
    }
  }

  static const FirebaseOptions _rescuerIosOptions = FirebaseOptions(
    apiKey: 'AIzaSyA3cUXkIjLsHhTv2l3OKhNzE3EZtejqxLg',
    appId: '1:494066243537:ios:8f122b25432725a6a4b2f0',
    messagingSenderId: '494066243537',
    projectId: 'life-line-rescuer-b1f1c',
    storageBucket: 'life-line-rescuer-b1f1c.firebasestorage.app',
    iosBundleId: 'com.example.lifeLineRescuer',
  );

  @override
  Widget build(BuildContext context) {
    final callAsync = ref.watch(incomingCallStreamProvider);

    return callAsync.when(
      loading:
          () => const Scaffold(
            backgroundColor: AppColors.softBackground,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryMaroon),
            ),
          ),
      error:
          (_, _) => const Scaffold(
            backgroundColor: AppColors.softBackground,
            body: Center(
              child: Text(
                "Error fetching call info",
                style: TextStyle(color: AppColors.primaryMaroon),
              ),
            ),
          ),
      data: (call) {
        if (call == null) {
          return const Scaffold(
            backgroundColor: AppColors.softBackground,
            body: SizedBox.shrink(),
          );
        }

        final callId = call['callId'] as String;
        final callerName = call['callerName'] ?? 'Unknown';
        final callerPhotoUrl = call['callerPhotoUrl'] ?? '';
        final audioOnly = call['audioOnly'] ?? false;

        return Scaffold(
          backgroundColor: AppColors.primaryMaroon,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Text(
                    audioOnly ? 'Incoming Voice Call' : 'Incoming Video Call',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  CircleAvatar(
                    radius: 64,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    backgroundImage:
                        callerPhotoUrl.isNotEmpty
                            ? NetworkImage(callerPhotoUrl)
                            : null,
                    child:
                        callerPhotoUrl.isEmpty
                            ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 56,
                            )
                            : null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    callerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _callActionButton(
                        icon: Icons.call_end_rounded,
                        color: Colors.red,
                        label: 'Decline',
                        onTap: () async {
                          await CallService.declineCall(
                            callId,
                            rescuerFirestore: rescuerFirestore!,
                          );
                        },
                      ),
                      _callActionButton(
                        icon: Icons.call_rounded,
                        color: Colors.green,
                        label: 'Accept',
                        onTap: () async {
                          if (!context.mounted) return;
                          ref.read(activeCallIdProvider.notifier).state =
                              callId;
                          await CallService.acceptCall(
                            callId: callId,
                            displayName: callerName,
                            avatarUrl: callerPhotoUrl,
                            audioOnly: audioOnly,
                            rescuerFirestore: rescuerFirestore!,
                          );
                          if (!context.mounted) return;
                          ref.read(activeCallIdProvider.notifier).state = null;
                        },
                      ),
                    ],
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _callActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 32,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
