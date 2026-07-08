import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:life_line_victim/styles/styles.dart';

class VictimBlockedDialog extends StatelessWidget {
  final String email;

  const VictimBlockedDialog({super.key, required this.email});

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
                      await FirebaseAuth.instance.signOut();
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
