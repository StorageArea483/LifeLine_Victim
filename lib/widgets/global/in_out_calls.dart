import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_victim/providers/call_state_provider.dart';
import 'package:life_line_victim/providers/incoming_call_provider.dart';
import 'package:life_line_victim/services/call_service.dart';
import 'package:life_line_victim/styles/styles.dart';
import 'package:life_line_victim/widgets/global/called_feedback_screen.dart';
import 'package:life_line_victim/widgets/global/incoming_call_screen.dart';
import 'package:life_line_victim/widgets/global/outgoing_calling_screen.dart';

import 'dart:io' show Platform;

class InOutCalls extends ConsumerStatefulWidget {
  final Widget child;
  const InOutCalls({super.key, required this.child});

  @override
  ConsumerState<InOutCalls> createState() => _InOutCallsState();
}

class _InOutCallsState extends ConsumerState<InOutCalls> {
  ProviderSubscription? _outgoingCallSubscription;
  ProviderSubscription? _incomingCallSubscription;
  FirebaseFirestore? rescuerFirestore;

  bool _hasJoinedJitsi = false;

  // life-line-rescuer database credentials
  static const FirebaseOptions _rescuerAndroidOptions = FirebaseOptions(
    apiKey: 'AIzaSyDs-CoAc_fqrB-3BMl4N7pYSavyNV72zUQ',
    appId: '1:494066243537:android:ffdb36137d6d3cb1a4b2f0',
    messagingSenderId: '494066243537',
    projectId: 'life-line-rescuer-b1f1c',
    storageBucket: 'life-line-rescuer-b1f1c.firebasestorage.app',
  );

  static const FirebaseOptions _rescuerIosOptions = FirebaseOptions(
    apiKey: 'AIzaSyA3cUXkIjLsHhTv2l3OKhNzE3EZtejqxLg',
    appId: '1:494066243537:ios:8f122b25432725a6a4b2f0',
    messagingSenderId: '494066243537',
    projectId: 'life-line-rescuer-b1f1c',
    storageBucket: 'life-line-rescuer-b1f1c.firebasestorage.app',
    iosBundleId: 'com.example.lifeLineRescuer',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSecondaryFirebase();
      _listenToCallState();
    });
  }

  @override
  void dispose() {
    _outgoingCallSubscription?.close();
    _incomingCallSubscription?.close();
    super.dispose();
  }

  Future<void> _initSecondaryFirebase() async {
    try {
      FirebaseApp rescuerApp;
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
      // Handle error silently
    }
  }

  void _listenToCallState() {
    // 1. Listener for Outgoing Call workflows
    _outgoingCallSubscription = ref.listenManual<
      AsyncValue<DocumentSnapshot?>
    >(currentCallDocStreamProvider, (previous, next) {
      if (!mounted) return;
      final currentCallId = ref.read(currentCallIdProvider);

      if (currentCallId == null) {
        _hasJoinedJitsi = false;
        return;
      }

      next.whenData((callDoc) {
        if (callDoc != null && callDoc.exists) {
          final callData = callDoc.data() as Map<String, dynamic>?;
          final callStatus = callData?['status'] ?? '';
          final senderId = callData?['senderId'] ?? '';
          final targetName = callData?['callerName'] ?? 'Caller';

          if (callStatus == 'ringing') {
            if (previous?.value == null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  settings: const RouteSettings(name: '/outgoing-call'),
                  builder:
                      (context) => OutgoingCallScreen(
                        callId: currentCallId,
                        receiverName: targetName,
                        rescuerFirestore:
                            rescuerFirestore ?? FirebaseFirestore.instance,
                      ),
                ),
              );
            }
          } else if (callStatus == 'accepted') {
            final currentUserId = FirebaseAuth.instance.currentUser?.uid;
            if (senderId == currentUserId && !_hasJoinedJitsi) {
              _hasJoinedJitsi = true;
              CallService.joinRoom(
                roomName: currentCallId,
                displayName: callData?['callerName'] ?? 'Unknown',
                avatarUrl: callData?['callerPhotoUrl'] ?? '',
                audioOnly: callData?['audioOnly'] ?? false,
                rescuerFirestore:
                    rescuerFirestore ?? FirebaseFirestore.instance,
              );
            }
            // Safely remove the outgoing call screen without popping the whole stack
            Navigator.of(
              context,
            ).popUntil((route) => route.settings.name != '/outgoing-call');
          } else if (callStatus == 'declined' || callStatus == 'ended') {
            CallService.hangUp();

            // Remove outgoing calling screen and present feedback
            Navigator.of(
              context,
            ).popUntil((route) => route.settings.name != '/outgoing-call');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => CallFeedbackScreen(
                      title:
                          callStatus == 'declined'
                              ? 'Call Declined'
                              : 'Call Ended',
                      subtitle:
                          callStatus == 'declined'
                              ? 'The recipient has declined your call.'
                              : 'The conversation has ended',
                      icon:
                          callStatus == 'declined'
                              ? Icons.gpp_bad_rounded
                              : Icons.phone_disabled_rounded,
                      iconColor: AppColors.error,
                    ),
              ),
            );
          }
        } else if (callDoc != null && !callDoc.exists) {
          CallService.hangUp();
          ref.read(currentCallIdProvider.notifier).state = null;
          Navigator.of(
            context,
          ).popUntil((route) => route.settings.name != '/outgoing-call');
        }
      });
    });

    // 2. Listener for Incoming Call Stream Provider
    _incomingCallSubscription = ref.listenManual<
      AsyncValue<Map<String, dynamic>?>
    >(incomingCallStreamProvider, (previous, next) {
      if (!mounted) return;

      next.whenData((incomingCallData) {
        if (incomingCallData != null && previous?.value == null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              settings: const RouteSettings(name: '/incoming-call'),
              builder: (context) => const IncomingCallScreen(),
            ),
          );
        } else if (incomingCallData == null && previous?.value != null) {
          // If the call document disappears or clears externally, dismiss the overlay screen automatically
          Navigator.of(
            context,
          ).popUntil((route) => route.settings.name != '/incoming-call');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
