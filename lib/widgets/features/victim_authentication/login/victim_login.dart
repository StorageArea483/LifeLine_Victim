import 'package:flutter/material.dart';
import 'package:life_line/widgets/constants/constants.dart';
import 'package:life_line/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_line/widgets/features/victim_authentication/login/password_forgot.dart';
import 'package:life_line/widgets/features/victim_authentication/sign_up/login_signup.dart';
import 'package:life_line/widgets/features/victim_dashboard/victim_page.dart';
import 'package:life_line/widgets/global/victim_blocked.dart';
import 'package:life_line/services/functions/transitions_in_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VictimLogin extends StatefulWidget {
  const VictimLogin({super.key});

  @override
  State<VictimLogin> createState() => _VictimLoginState();
}

class _VictimLoginState extends State<VictimLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final query =
          await FirebaseFirestore.instance
              .collection('victim-info-database')
              .where('emailAddress', isEqualTo: email)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        final storedPassword = (data['password'] ?? '').toString();

        if (storedPassword == password) {
          final bool isBlocked = data['blocked'] ?? false;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userEmail', email);

          if (mounted) {
            if (isBlocked) {
              pageTransition(context, VictimBlocked(userEmail: email));
            } else {
              pageTransition(context, const VictimPage());
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Incorrect email or password'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No account found with this email'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppContainers.pageContainer,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.darkCharcoal,
                          size: 24,
                        ),
                        onPressed:
                            () => pageTransition(context, const LoginSignup()),
                      ),
                      const Spacer(),
                      const Text('Login', style: AppText.appHeader),
                      const Spacer(flex: 2),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: AppTextFields.textFieldDecoration(
                            'Email or Username',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'This field is required';
                            }
                            final email = value.trim();
                            if (!RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            ).hasMatch(email)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: AppTextFields.textFieldDecoration(
                            'Password',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'This field is required';
                            }
                            if (value.trim().length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed:
                              () => pageTransition(
                                context,
                                const PasswordForgot(),
                              ),
                          child: const Text(
                            'Forgot Password?',
                            style: AppText.link,
                          ),
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: AppButtons.submit,
                            onPressed: _isLoading ? null : _handleLogin,
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                    : const Text('Login'),
                          ),
                        ),
                      ],
                    ),
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
