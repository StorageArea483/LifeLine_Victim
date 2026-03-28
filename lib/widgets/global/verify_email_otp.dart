import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/providers/loading_state_provider.dart';
import 'package:life_line/styles/styles.dart';
import 'package:life_line/widgets/features/victim_authentication/sign_up/victim_signup.dart';
import 'package:life_line/widgets/features/victim_dashboard/victim_page.dart';
import 'package:life_line/widgets/features/victim_authentication/login/change_password.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class VerifyEmailOtp extends ConsumerStatefulWidget {
  final String? firstName;
  final String? lastName;
  final String emailAddress;
  final String? password;
  final String? phoneNumber;
  final bool isSignUp;
  final bool isLogin;

  const VerifyEmailOtp({
    super.key,
    this.firstName,
    this.lastName,
    required this.emailAddress,
    this.password,
    this.phoneNumber,
    required this.isSignUp,
    required this.isLogin,
  });

  @override
  ConsumerState<VerifyEmailOtp> createState() => _VerifyEmailOtpState();
}

class _VerifyEmailOtpState extends ConsumerState<VerifyEmailOtp> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  static const String _senderEmail = 'sajidaryan378@gmail.com';
  static const String _appPassword = 'whrizhmeuxpwokma';

  String? _generatedOtp;

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Generate a simple 6-digit OTP
  String _generateOtp() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final code = (now % 1000000).toString().padLeft(6, '0');
    return code;
  }

  Message _createOtpMessage(String to, String code) {
    final msg = Message();
    msg.from = const Address(_senderEmail, 'LifeLine');
    msg.recipients = [to];
    msg.subject = 'Your LifeLine verification code';
    msg.text = 'Your verification code is: $code\nThis code will expire soon.';
    return msg;
  }

  // Send OTP via Gmail SMTP using mailer
  Future<void> _sendOTP() async {
    if (mounted) {
      ref.read(isLoadingStateProvider.notifier).state = true;
    }

    try {
      _generatedOtp = _generateOtp();

      final smtpServer = gmail(_senderEmail, _appPassword);
      final message = _createOtpMessage(widget.emailAddress, _generatedOtp!);

      await send(message, smtpServer);

      if (mounted) {
        ref.read(isLoadingStateProvider.notifier).state = false;
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully to your email!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ref.read(isLoadingStateProvider.notifier).state = false;
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Verify OTP by comparing with the generated code
  Future<void> _verifyOTP(String otp) async {
    if (mounted) {
      ref.read(isLoadingStateProvider.notifier).state = true;
    }

    final bool isValid = _generatedOtp != null && otp == _generatedOtp;

    if (!isValid) {
      if (mounted) {
        ref.read(isLoadingStateProvider.notifier).state = false;
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid OTP. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // OTP verified
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }

    try {
      // Navigate based on isSignUp and isLogin flags
      if (widget.isSignUp && !widget.isLogin) {
        // User is signing up - insert data into Firestore
        await FirebaseFirestore.instance
            .collection('victim-info-database')
            .add({
              'firstName': widget.firstName,
              'lastName': widget.lastName,
              'emailAddress': widget.emailAddress,
              'password': widget.password,
              'phoneNumber': widget.phoneNumber,
              'approved': false,
            });

        if (mounted) {
          ref.read(isLoadingStateProvider.notifier).state = false;
        }

        // Navigate to VictimPage
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const VictimPage()),
          );
        }
      } else if (!widget.isSignUp && widget.isLogin) {
        if (mounted) {
          ref.read(isLoadingStateProvider.notifier).state = false;
        }

        // User is resetting password - navigate to ChangePassword
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) =>
                      ChangePassword(emailAddress: widget.emailAddress),
            ),
          );
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete operation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (mounted) {
        ref.read(isLoadingStateProvider.notifier).state = false;
      }
    }
  }

  // Resend OTP: regenerate and email again
  Future<void> _resendOTP() async {
    if (mounted) {
      ref.read(isResendLoadingStateProvider.notifier).state = true;
    }

    try {
      _generatedOtp = _generateOtp();

      final smtpServer = gmail(_senderEmail, _appPassword);
      final message = _createOtpMessage(widget.emailAddress, _generatedOtp!);

      await send(message, smtpServer);

      if (mounted) {
        ref.read(isResendLoadingStateProvider.notifier).state = false;
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully to your email!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ref.read(isResendLoadingStateProvider.notifier).state = false;
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resending OTP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getOTP() {
    return _otpControllers.map((controller) => controller.text).join();
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
                MaterialPageRoute(builder: (context) => const VictimSignup()),
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
                        'Verify Your Email',
                        style: AppText.subtitle.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Verification Container with Modern Design
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Enter the code',
                        style: AppText.welcomeTitle.copyWith(
                          color: AppColors.primaryMaroon,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'We sent a verification code to ${widget.emailAddress}',
                        textAlign: TextAlign.center,
                        style: AppText.subtitle.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // OTP Input Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            height: 55,
                            child: TextField(
                              controller: _otpControllers[index],
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              cursorColor: AppColors.primaryMaroon,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkCharcoal,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  if (index < 5) {
                                    FocusScope.of(context).nextFocus();
                                  } else {
                                    FocusScope.of(context).unfocus();
                                  }
                                }
                              },
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.surfaceLight,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryMaroon,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 40),

                      // Resend Code Section
                      Column(
                        children: [
                          const Text(
                            "Didn't receive the code?",
                            style: AppText.base,
                          ),
                          const SizedBox(height: 8),
                          Consumer(
                            builder: (context, ref, child) {
                              final isResendLoading = ref.watch(
                                isResendLoadingStateProvider,
                              );
                              return GestureDetector(
                                onTap: isResendLoading ? null : _resendOTP,
                                child:
                                    isResendLoading
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.primaryMaroon,
                                                ),
                                          ),
                                        )
                                        : const Text(
                                          'Resend Code',
                                          style: AppText.base,
                                        ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

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
                            final isLoading = ref.read(isLoadingStateProvider);
                            if (!isLoading) {
                              String otp = _getOTP();
                              if (otp.length == 6) {
                                _verifyOTP(otp);
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter the complete 6-digit OTP',
                                      ),
                                      backgroundColor: AppColors.warning,
                                    ),
                                  );
                                }
                              }
                            }
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
                                    'Verify',
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
                      'Secure verification process',
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
}
