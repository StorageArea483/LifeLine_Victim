import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:life_line/styles/styles.dart';
import 'package:life_line/widgets/google_authentication.dart';

class GoogleSignup extends StatelessWidget {
  const GoogleSignup({super.key});

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
                // Logo and App Name
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Image.asset(
                          'assets/images/app_bg_removed.png',

                          width: 100,

                          height: 100,
                        ),
                      ),

                      const Text(
                        'LifeLine',

                        style: TextStyle(
                          fontFamily: 'SFPro',

                          fontSize: 28,

                          fontWeight: FontWeight.w800,

                          color: AppColors.primaryMaroon,

                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Emergency Response Platform',

                        style: AppText.subtitle.copyWith(
                          color: AppColors.textSecondary,

                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // Hero Section
                Container(
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryMaroon.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/community_join_image.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Feature Cards
                _buildFeatureCard(
                  icon: Icons.flash_on,

                  title: 'Fast Response',

                  description: 'Get immediate help during emergencies',

                  color: AppColors.warning,
                ),

                const SizedBox(height: 16),

                _buildFeatureCard(
                  icon: Icons.location_on,

                  title: 'Location Sharing',

                  description: 'Share your location with rescuers',

                  color: AppColors.info,
                ),

                const SizedBox(height: 16),

                _buildFeatureCard(
                  icon: Icons.people,

                  title: 'NGO Network',

                  description: 'Connect with verified organizations',

                  color: AppColors.success,
                ),

                const SizedBox(height: 40),

                // Primary CTA
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Consumer(
                    builder: (context, ref, child) {
                      return GoogleAuthentication(ref);
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Terms Footer
                RichText(
                  textAlign: TextAlign.center,

                  text: TextSpan(
                    style: AppText.footer.copyWith(color: AppColors.textLight),

                    children: [
                      const TextSpan(text: 'By continuing, you agree to our '),

                      WidgetSpan(
                        child: GestureDetector(
                          onTap:
                              () => showPolicyDialog(
                                context,

                                'Terms of Service',

                                termsOfService,
                              ),

                          child: Text(
                            'Terms of Service',

                            style: AppText.footerLink.copyWith(
                              color: AppColors.primaryMaroon,

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const TextSpan(text: ' and '),

                      WidgetSpan(
                        child: GestureDetector(
                          onTap:
                              () => showPolicyDialog(
                                context,

                                'Privacy Policy',

                                privacyPolicy,
                              ),

                          child: Text(
                            'Privacy Policy',

                            style: AppText.footerLink.copyWith(
                              color: AppColors.primaryMaroon,

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,

    required String title,

    required String description,

    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.surfaceLight,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: AppColors.borderColor, width: 1),

        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,

            blurRadius: 10,

            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 48,

            height: 48,

            decoration: BoxDecoration(
              color: color.withOpacity(0.1),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, size: 24, color: color),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: AppText.fieldLabel.copyWith(
                    fontWeight: FontWeight.w600,

                    color: AppColors.darkCharcoal,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,

                  style: AppText.small.copyWith(
                    color: AppColors.textSecondary,

                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showPolicyDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,

      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            child: Container(
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: AppColors.surfaceLight,

                borderRadius: BorderRadius.circular(20),
              ),

              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppText.formTitle.copyWith(
                        color: AppColors.primaryMaroon,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      body,
                      style: AppText.formDescription.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),

                                side: const BorderSide(
                                  color: AppColors.primaryMaroon,

                                  width: 1,
                                ),
                              ),
                            ),

                            onPressed: () {
                              if (ctx.mounted) {
                                Navigator.of(ctx).pop();
                              }
                            },

                            child: Text(
                              'Close',

                              style: AppText.button.copyWith(
                                color: AppColors.primaryMaroon,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            style: AppButtons.primary,

                            onPressed: () {
                              if (ctx.mounted) {
                                Navigator.of(ctx).pop();
                              }

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'You agreed to our terms and conditions.',

                                      textAlign: TextAlign.center,

                                      style: TextStyle(
                                        fontSize: 14,

                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    backgroundColor: AppColors.success,

                                    behavior: SnackBarBehavior.floating,

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
                            },

                            child: Text(
                              'I Agree',

                              style: AppText.button.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
