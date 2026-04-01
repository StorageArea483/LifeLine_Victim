import 'package:flutter/material.dart';
import 'package:life_line/pages/google_signup.dart';
import 'package:life_line/styles/styles.dart';

class VictimBlocked extends StatelessWidget {
  final String userEmail;

  const VictimBlocked({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppContainers.pageContainer,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'LifeLine',
                          style: TextStyle(
                            fontFamily: 'SFPro',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),

                const Spacer(),

                // Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_outlined,
                      size: 60,
                      color: AppColors.error,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'Access Restricted',
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                    color: AppColors.darkCharcoal,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  'Your account associated with $userEmail has been restricted from using LifeLine services due to a violation of our terms of service.',
                  style: const TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: AppButtons.submit,
                      onPressed: () {
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const GoogleSignup(),
                            ),
                          );
                        }
                      },
                      child: const Text('Return to SignUp page'),
                    ),
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
