import 'package:flutter/material.dart';
import 'package:life_line/widgets/features/victim_authentication/sign_up/welcome_page.dart';
import 'package:life_line/styles/styles.dart';

class VictimEntryScreen extends StatelessWidget {
  const VictimEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: Container(
        decoration: AppContainers.pageContainer,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                // App badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMaroon.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/app_logo.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'LifeLine',
                        style: TextStyle(
                          fontFamily: 'SFPro',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryMaroon,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Main headline
                Text(
                  'We\'re here\nto help you.',
                  style: AppText.welcomeTitle.copyWith(
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Request emergency assistance, connect\nwith rescuers, and get support fast.',
                  style: AppText.subtitle,
                ),

                const Spacer(),

                // Illustration / visual block
                Center(
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.primaryMaroon.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.primaryMaroon.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            size: 36,
                            color: AppColors.primaryMaroon,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Emergency Response Platform',
                          style: AppText.formDescription.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryMaroon,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Available 24/7 during disasters',
                          style: AppText.formDescription,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Quick info strip
                const Row(
                  children: [
                    _InfoChip(icon: Icons.bolt_rounded, label: 'Fast Response'),
                    SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.lock_outline_rounded,
                      label: 'Secure',
                    ),
                    SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.groups_outlined,
                      label: 'NGO Network',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Primary CTA
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.primaryButtonHeight,
                  child: ElevatedButton(
                    style: AppButtons.primary,
                    onPressed:
                        () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const WelcomePage(),
                          ),
                        ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Get Started', style: AppText.submitButton),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Terms footer
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'By continuing, you agree to our',
                        style: AppText.footer,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
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
                              ),
                            ),
                          ),
                          const Text(' and ', style: AppText.footer),
                          GestureDetector(
                            onTap:
                                () => showPolicyDialog(
                                  context,
                                  'Privacy Policy',
                                  privacyPolicy,
                                ),
                            child: Text(
                              'Privacy Policy.',
                              style: AppText.footerLink.copyWith(
                                color: AppColors.primaryMaroon,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showPolicyDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w700,
                color: AppColors.primaryMaroon,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Text(
                  body,
                  style: const TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 18,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: AppColors.primaryMaroon,
                    fontFamily: 'SFPro',
                  ),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryMaroon,
                  side: const BorderSide(
                    color: AppColors.primaryMaroon,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'You agreed to our terms and conditions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'SFPro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'I Agree',
                  style: TextStyle(
                    color: AppColors.primaryMaroon,
                    fontFamily: 'SFPro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryMaroon),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppText.formDescription.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
