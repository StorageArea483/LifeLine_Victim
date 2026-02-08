import 'package:flutter/material.dart';
import 'package:life_line/widgets/features/victim_authentication/login/victim_login.dart';
import 'package:life_line/widgets/global/role_select_screen.dart';
import 'package:life_line/widgets/constants/constants.dart';
import 'package:life_line/widgets/features/victim_authentication/sign_up/victim_signup.dart';
import 'package:life_line/services/functions/transitions_in_pages.dart';
import 'package:life_line/utils/styles.dart';

class LoginSignup extends StatelessWidget {
  const LoginSignup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppContainers.pageContainer,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.darkCharcoal,
                          size: 24,
                        ),
                        onPressed:
                            () => pageTransition(
                              context,
                              const RoleSelectScreen(),
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Community Image - simplified, no shadow
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/community_join_image.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Join Our Community',
                  textAlign: TextAlign.center,
                  style: AppText.welcomeTitle,
                ),

                const SizedBox(height: 8),

                const Text(
                  'Be a part of a network dedicated to providing\nsupport and assistance during emergencies',
                  textAlign: TextAlign.center,
                  style: AppText.subtitle,
                ),

                const SizedBox(height: 20),

                // Buttons card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text('Get Started', style: AppText.formTitle),
                          const SizedBox(height: 8),
                          const Text(
                            'Choose how you want to continue',
                            style: AppText.formDescription,
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: AppButtons.submit,
                              onPressed:
                                  () => pageTransition(
                                    context,
                                    const VictimLogin(),
                                  ),
                              child: const Text('Login'),
                            ),
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: AppButtons.submit,
                              onPressed:
                                  () => pageTransition(
                                    context,
                                    const VictimSignup(),
                                  ),
                              child: const Text('Sign Up'),
                            ),
                          ),
                        ],
                      ),
                    ),
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
}
