import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_victim/pages/landing_page.dart';
import 'package:life_line_victim/styles/styles.dart';
import 'package:life_line_victim/utils/responsive_helper.dart';
import 'package:life_line_victim/widgets/global/page_message.dart';
import 'package:life_line_victim/widgets/global/page_navigation.dart';
import 'dart:async';

class VictimWaitingScreen extends ConsumerStatefulWidget {
  final String requestType;
  const VictimWaitingScreen({super.key, required this.requestType});

  @override
  ConsumerState<VictimWaitingScreen> createState() => _VictimWaitingState();
}

class _VictimWaitingState extends ConsumerState<VictimWaitingScreen> {
  FirebaseFirestore? _ngoFirestore;

  // Firebase configuration for life-line-ngo
  static const FirebaseOptions _ngoFirebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyBeieryGaw4bh4dtbrI54qsIc51XkP6SoM',
    appId: '1:169949190544:web:2640453ce5dd2aa55d3b15',
    messagingSenderId: '169949190544',
    projectId: 'life-line-ngo',
    authDomain: 'life-line-ngo.firebaseapp.com',
    storageBucket: 'life-line-ngo.firebasestorage.app',
  );

  @override
  void initState() {
    super.initState();
    _initSecondaryFirebase();
  }

  Future<void> _initSecondaryFirebase() async {
    try {
      FirebaseApp ngoApp;
      try {
        ngoApp = Firebase.app('life-line-ngo');
      } catch (_) {
        ngoApp = await Firebase.initializeApp(
          name: 'life-line-ngo',
          options: _ngoFirebaseOptions,
        );
      }
      _ngoFirestore = FirebaseFirestore.instanceFor(app: ngoApp);
    } catch (e) {
      if (mounted) {
        pageMessage(
          'An unexpected error occurred please retry',
          context,
          AppColors.error,
        );
      }
    }
  }

  String? _getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<void> _removeUserRequest() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      if (_ngoFirestore == null) {
        FirebaseApp ngoApp;
        try {
          ngoApp = Firebase.app('life-line-ngo');
        } catch (_) {
          ngoApp = await Firebase.initializeApp(
            name: 'life-line-ngo',
            options: _ngoFirebaseOptions,
          );
        }
        _ngoFirestore = FirebaseFirestore.instanceFor(app: ngoApp);
      }

      await _ngoFirestore!.collection('requests').doc(userId).delete();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: SafeArea(child: Center(child: _buildWaitingCard(context))),
    );
  }

  Widget _buildWaitingCard(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveHelper.isTablet(context) ? 650 : 500,
        ),
        margin: const EdgeInsets.all(24),
        padding: EdgeInsets.all(ResponsiveHelper.isTablet(context) ? 48 : 32),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkCharcoal.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Image.asset(
                'assets/images/loading.gif',
                width: ResponsiveHelper.isTablet(context) ? 180 : 120,
                height: ResponsiveHelper.isTablet(context) ? 180 : 120,
                errorBuilder: (context, error, stackTrace) {
                  return const CircularProgressIndicator(
                    color: AppColors.primaryMaroon,
                  );
                },
              ),
            ),
            SizedBox(height: ResponsiveHelper.isTablet(context) ? 28 : 20),
            Text(
              'Request Sent',
              style: AppText.formTitle.copyWith(
                fontSize: ResponsiveHelper.titleFont(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please wait, the NGO will respond shortly.',
              style: AppText.small.copyWith(
                height: 1.5,
                fontSize: ResponsiveHelper.bodyFont(context),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.isTablet(context) ? 36 : 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  if (!mounted) return;
                  try {
                    await _removeUserRequest();
                    pageNavigation(const LandingPage(), context);
                  } catch (e) {
                    if (mounted) {
                      pageMessage(
                        'Failed to remove request, an unexpected error occurred $e',
                        context,
                        AppColors.error,
                      );
                    }
                  }
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.error,
                  size: ResponsiveHelper.isTablet(context) ? 22 : 18,
                ),
                label: Text(
                  'Remove ${widget.requestType} Request',
                  textAlign: TextAlign.center,
                  style: AppText.button.copyWith(
                    fontSize: ResponsiveHelper.bodyFont(context),
                    color: AppColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveHelper.isTablet(context) ? 18 : 14,
                  ),
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
