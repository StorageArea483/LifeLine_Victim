import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:life_line_victim/pages/google_signup.dart';
import 'package:life_line_victim/styles/styles.dart';
import 'package:life_line_victim/widgets/global/internet_connection.dart';
import 'package:life_line_victim/widgets/global/page_message.dart';
import 'package:life_line_victim/widgets/global/page_navigation.dart';

class VictimBlockedDialog extends StatelessWidget {
  final String email;

  const VictimBlockedDialog({super.key, required this.email});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
      }

      pageNavigation(const InternetConnection(child: GoogleSignup()), context);
    } catch (e) {
      if (context.mounted) {
        pageMessage(
          'Failed to logout. Please try again.',
          context,
          AppColors.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_outlined,
                      size: 50,
                      color: AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Access Restricted',
                  style: AppText.formTitle,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  'Your account associated with $email has been restricted from using LifeLine services due to a violation of our terms of service.',
                  style: AppText.small.copyWith(height: 1.5),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: AppButtons.submit,
                    onPressed: () async {
                      await _handleLogout(context);
                    },
                    child: const Text('Sign Out', style: AppText.submitButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
