import 'package:flutter/material.dart';
import 'package:life_line/services/functions/terms_and_conditions.dart';
import 'package:life_line/widgets/constants/constants.dart';
import 'package:life_line/widgets/features/victim_authentication/sign_up/login_signup.dart';
import 'package:life_line/services/functions/transitions_in_pages.dart';
import 'package:life_line/utils/styles.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppContainers.pageContainer,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Disaster Relief & Emergency\nResponse',
                  textAlign: TextAlign.center,
                  style: AppText.appHeader,
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome', style: AppText.welcomeTitle),
                        const SizedBox(height: 12),
                        const Text(
                          'Select your role to get started.',
                          style: AppText.subtitle,
                        ),
                        const SizedBox(height: 24),

                        _PrimaryButton(
                          icon: Icons.person_outline_rounded,
                          label: 'Victim',
                          onPressed:
                              () =>
                                  pageTransition(context, const LoginSignup()),
                        ),
                        const SizedBox(height: 14),
                        _PrimaryButton(
                          icon: Icons.volunteer_activism_outlined,
                          label: 'Rescuer',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'By continuing, you agree to our',
                      style: AppText.small,
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
                          child: const Text(
                            'Terms of Service',
                            style: AppText.link,
                          ),
                        ),
                        const Text(' and ', style: AppText.small),
                        GestureDetector(
                          onTap:
                              () => showPolicyDialog(
                                context,
                                'Privacy Policy',
                                privacyPolicy,
                              ),
                          child: const Text(
                            'Privacy Policy.',
                            style: AppText.link,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: AppButtons.primary,
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: Colors.white),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }
}
