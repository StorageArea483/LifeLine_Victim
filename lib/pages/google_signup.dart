import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:life_line_victim/styles/styles.dart';
import 'package:life_line_victim/widgets/global/page_message.dart';
import 'package:life_line_victim/widgets/google_authentication.dart';
import 'package:life_line_victim/utils/responsive_helper.dart';

class GoogleSignup extends StatelessWidget {
  const GoogleSignup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: SafeArea(
        child: Container(
          decoration: AppContainers.pageContainer,
          child: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: ResponsiveHelper.contentWidth(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.horizontalPadding(context),
                    vertical: ResponsiveHelper.verticalPadding(context),
                  ),
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
                                'assets/images/app_bg_removed.webp',
                                width:
                                    ResponsiveHelper.isTablet(context)
                                        ? 140
                                        : 100,
                                height:
                                    ResponsiveHelper.isTablet(context)
                                        ? 140
                                        : 100,
                              ),
                            ),

                            Text(
                              'LifeLine',
                              style: AppText.title.copyWith(
                                fontSize:
                                    ResponsiveHelper.isTablet(context)
                                        ? 42
                                        : 32,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Emergency Response Platform',

                              style: AppText.subtitle.copyWith(
                                fontSize:
                                    ResponsiveHelper.isTablet(context)
                                        ? 18
                                        : 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 45 : 35,
                      ),

                      // Hero Section
                      Center(
                        child: Container(
                          width: double.infinity,
                          height:
                              ResponsiveHelper.isTablet(context) ? 320 : 240,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryMaroon.withOpacity(
                                  0.15,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/images/community_join_image.webp',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 50 : 40,
                      ),

                      // Feature Cards
                      _buildFeatureCard(
                        context,
                        icon: Icons.flash_on,

                        title: 'Fast Response',

                        description: 'Get immediate help during emergencies',

                        color: AppColors.warning,
                      ),

                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 24 : 16,
                      ),

                      _buildFeatureCard(
                        context,
                        icon: Icons.location_on,

                        title: 'Location Sharing',

                        description: 'Share your location with rescuers',

                        color: AppColors.info,
                      ),

                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 24 : 16,
                      ),

                      _buildFeatureCard(
                        context,
                        icon: Icons.people,

                        title: 'NGO Network',

                        description: 'Connect with verified organizations',

                        color: AppColors.success,
                      ),

                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 50 : 40,
                      ),

                      // Primary CTA
                      SizedBox(
                        width: double.infinity,
                        height: ResponsiveHelper.buttonHeight(context),
                        child: Consumer(
                          builder: (context, ref, child) {
                            return GoogleAuthentication(ref);
                          },
                        ),
                      ),

                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 40 : 30,
                      ),

                      // Terms Footer
                      RichText(
                        textAlign: TextAlign.center,

                        text: TextSpan(
                          style: AppText.footer.copyWith(
                            color: AppColors.textLight,
                            fontSize: ResponsiveHelper.bodyFont(context),
                          ),

                          children: [
                            const TextSpan(
                              text: 'By continuing, you agree to our ',
                            ),

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
                                    fontSize: ResponsiveHelper.bodyFont(
                                      context,
                                    ),
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
                                    fontSize: ResponsiveHelper.bodyFont(
                                      context,
                                    ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,

    required String title,

    required String description,

    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.isTablet(context) ? 28 : 20),

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
            width: ResponsiveHelper.isTablet(context) ? 60 : 48,

            height: ResponsiveHelper.isTablet(context) ? 60 : 48,

            decoration: BoxDecoration(
              color: color.withOpacity(0.1),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              size: ResponsiveHelper.isTablet(context) ? 30 : 24,
              color: color,
            ),
          ),

          SizedBox(width: ResponsiveHelper.isTablet(context) ? 20 : 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: AppText.fieldLabel.copyWith(
                    fontSize: ResponsiveHelper.isTablet(context) ? 18 : 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,

                  style: AppText.small.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: ResponsiveHelper.isTablet(context) ? 16 : 13,
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

            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:
                    ResponsiveHelper.isTablet(context) ? 650 : double.infinity,
              ),
              child: Container(
                padding: EdgeInsets.all(
                  ResponsiveHelper.isTablet(context) ? 32 : 24,
                ),

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
                          fontSize: ResponsiveHelper.titleFont(context),
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 24 : 16,
                      ),
                      Text(
                        body,
                        style: AppText.formDescription.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: ResponsiveHelper.bodyFont(context),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.isTablet(context) ? 32 : 24,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: ResponsiveHelper.buttonHeight(context),
                              child: TextButton(
                                style: TextButton.styleFrom(
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
                                    fontSize: ResponsiveHelper.bodyFont(
                                      context,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: ResponsiveHelper.isTablet(context) ? 16 : 12,
                          ),

                          Expanded(
                            child: SizedBox(
                              height: ResponsiveHelper.buttonHeight(context),
                              child: ElevatedButton(
                                style: AppButtons.primary,

                                onPressed: () {
                                  if (ctx.mounted) {
                                    Navigator.of(ctx).pop();
                                  }

                                  pageMessage(
                                    'You agreed to our terms and conditions.',
                                    context,
                                    AppColors.success,
                                  );
                                },

                                child: Text(
                                  'I Agree',

                                  style: AppText.button.copyWith(
                                    color: AppColors.white,
                                    fontSize: ResponsiveHelper.bodyFont(
                                      context,
                                    ),
                                  ),
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
          ),
    );
  }
}
