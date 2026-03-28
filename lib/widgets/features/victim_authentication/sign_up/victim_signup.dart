import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/providers/loading_state_provider.dart';
import 'package:life_line/providers/toggle_state_provider.dart';
import 'package:life_line/widgets/global/verify_email_otp.dart';
import 'package:life_line/widgets/global/welcome_page.dart';
import 'package:life_line/styles/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VictimSignup extends ConsumerStatefulWidget {
  const VictimSignup({super.key});

  @override
  ConsumerState<VictimSignup> createState() => _VictimSignupState();
}

class _VictimSignupState extends ConsumerState<VictimSignup> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (mounted) {
      ref.read(isLoadingStateProvider.notifier).state = true;
    }

    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    try {
      final emailQuery =
          await FirebaseFirestore.instance
              .collection('victim-info-database')
              .where('emailAddress', isEqualTo: email)
              .limit(1)
              .get();

      if (emailQuery.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This email is already registered.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final phoneQuery =
          await FirebaseFirestore.instance
              .collection('victim-info-database')
              .where('phoneNumber', isEqualTo: phone)
              .limit(1)
              .get();

      if (phoneQuery.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This phone number is already registered.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', email);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => VerifyEmailOtp(
                  firstName: _firstNameController.text.trim(),
                  lastName: _lastNameController.text.trim(),
                  emailAddress: email,
                  password: _passwordController.text.trim(),
                  phoneNumber: phone,
                  isSignUp: true,
                  isLogin: false,
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong. Please try again. $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) ref.read(isLoadingStateProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7E8EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.darkCharcoal,
            size: 20,
          ),
          onPressed: () {
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const WelcomePage()),
              );
            }
          },
        ),
      ),
      body: Container(
        decoration: AppContainers.pageContainer,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // Logo Section
                Center(
                  child: Column(
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
                      const SizedBox(height: 8),
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
                        'Create Your Account',
                        style: AppText.subtitle.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Form Container with Modern Design
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: AppText.formTitle.copyWith(
                            color: AppColors.primaryMaroon,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please provide your details to continue',
                          style: AppText.formDescription.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildTextField(
                          'First Name',
                          'Enter your first name',
                          _firstNameController,
                          true,
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          'Last Name',
                          'Enter your last name',
                          _lastNameController,
                          true,
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          'Email Address',
                          'Enter your email',
                          _emailController,
                          false,
                        ),
                        const SizedBox(height: 20),

                        // Phone Number
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phone Number',
                              style: AppText.fieldLabel.copyWith(
                                color: AppColors.darkCharcoal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              validator: (value) {
                                final v = value?.trim() ?? '';
                                if (v.isEmpty) {
                                  return 'This field is required';
                                }
                                if (!RegExp(r'^\d{11}$').hasMatch(v)) {
                                  return 'Enter exactly 11 digits';
                                }
                                return null;
                              },
                              decoration: AppTextFields.textFieldDecoration(
                                '03XXXXXXXXX',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Password
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: AppText.fieldLabel.copyWith(
                                color: AppColors.darkCharcoal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Consumer(
                              builder: (context, ref, child) {
                                final togglePasswordVisibility = ref.watch(
                                  toggleStateProvider,
                                );
                                return TextFormField(
                                  controller: _passwordController,
                                  obscureText: !togglePasswordVisibility,
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'This field is required';
                                    }
                                    if (value.trim().length < 8) {
                                      return 'Password must be at least 8 characters';
                                    }
                                    return null;
                                  },
                                  decoration: AppTextFields.textFieldDecoration(
                                    'Create a strong password',
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        ref
                                            .read(toggleStateProvider.notifier)
                                            .state = !togglePasswordVisibility;
                                      },
                                      icon: Icon(
                                        togglePasswordVisibility
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Primary CTA with Gradient
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryMaroon,
                                AppColors.accentRose,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryMaroon.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              final isLoading = ref.read(
                                isLoadingStateProvider,
                              );
                              if (!isLoading) _handleSubmit();
                            },
                            child: Consumer(
                              builder: (context, ref, child) {
                                final isLoading = ref.watch(
                                  isLoadingStateProvider,
                                );
                                return isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      'Create Account',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontFamily: 'SFPro',
                                      ),
                                    );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Trust Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: AppColors.primaryMaroon.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Your information is safe and secure',
                      style: AppText.small.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hintText,
    TextEditingController controller,
    bool isName,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.fieldLabel.copyWith(
            color: AppColors.darkCharcoal,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType:
              isName ? TextInputType.text : TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            if (isName) {
              if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                return 'Name should only contain letters and spaces';
              }
            } else {
              final email = value.trim().toLowerCase();

              // Must match: anything@gmail.com exactly
              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(email)) {
                return 'Please enter a valid address (e.g. example@gmail.com)';
              }

              // Local part (before @) must be at least 6 characters
              final localPart = email.split('@')[0];
              if (localPart.length < 6) {
                return 'Gmail username must be at least 6 characters';
              }

              // Local part cannot start or end with a dot
              if (localPart.startsWith('.') || localPart.endsWith('.')) {
                return 'Gmail address cannot start or end with a dot';
              }

              // Local part cannot have consecutive dots
              if (localPart.contains('..')) {
                return 'Gmail address cannot contain consecutive dots';
              }
            }
            return null;
          },
          decoration: AppTextFields.textFieldDecoration(hintText),
        ),
      ],
    );
  }
}
