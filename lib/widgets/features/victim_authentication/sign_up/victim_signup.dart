import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/providers/loading_state_provider.dart';
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
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
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
          onPressed:
              () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const WelcomePage()),
              ),
        ),
      ),
      body: Container(
        decoration: AppContainers.pageContainer,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/app_bg_removed.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Disaster Relief & Emergency\nResponse',
                  textAlign: TextAlign.center,
                  style: AppText.appHeader,
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enter Your Information',
                              style: AppText.formTitle,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Please provide your details below.',
                              style: AppText.formDescription,
                            ),
                            const SizedBox(height: 24),

                            _buildTextField(
                              'First Name',
                              'Ali',
                              _firstNameController,
                              true,
                            ),
                            const SizedBox(height: 16),

                            _buildTextField(
                              'Last Name',
                              'Ahmed',
                              _lastNameController,
                              true,
                            ),
                            const SizedBox(height: 16),

                            _buildTextField(
                              'Email Address',
                              'example@gmail.com',
                              _emailController,
                              false,
                            ),
                            const SizedBox(height: 16),

                            // Phone Number
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Phone Number',
                                  style: AppText.fieldLabel,
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
                            const SizedBox(height: 16),

                            // Password
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Password',
                                  style: AppText.fieldLabel,
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
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
                                    'Enter password',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final isLoading = ref.watch(
                                    isLoadingStateProvider,
                                  );
                                  return ElevatedButton(
                                    style: AppButtons.submit,
                                    onPressed: isLoading ? null : _handleSubmit,
                                    child:
                                        isLoading
                                            ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                            : const Text('Submit'),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildTextField(
    String label,
    String hintText,
    TextEditingController controller,
    bool isName,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.fieldLabel),
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
              if (!RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              ).hasMatch(value.trim())) {
                return 'Please enter a valid email address';
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
