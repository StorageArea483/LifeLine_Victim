import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/providers/loading_state_provider.dart';
import 'package:life_line/styles/styles.dart';
import 'package:life_line/widgets/features/victim_authentication/sign_up/victim_signup.dart';
import 'package:life_line/pages/victim_page.dart';
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

class _VerifyEmailOtpState extends ConsumerState<VerifyEmailOtp>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  static const String _senderEmail = 'sajidaryan378@gmail.com';
  static const String _appPassword = 'pxny wkpa txpm wxti';

  String? _generatedOtp;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
    _sendOTP();
  }

  @override
  void dispose() {
    _animController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

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
          SnackBar(
            content: const Text('OTP sent successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

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
          SnackBar(
            content: const Text('Invalid OTP. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email verified successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    try {
      if (widget.isSignUp && !widget.isLogin) {
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

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const VictimPage()),
          );
        }
      } else if (!widget.isSignUp && widget.isLogin) {
        if (mounted) {
          ref.read(isLoadingStateProvider.notifier).state = false;
        }

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
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      if (mounted) {
        ref.read(isLoadingStateProvider.notifier).state = false;
      }
    }
  }

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
          SnackBar(
            content: const Text('OTP resent successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
      backgroundColor: const Color(0xFFF7E8EC),
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
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/app_bg_removed.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Verify your email',
                      style: TextStyle(
                        fontFamily: 'SFPro',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkCharcoal,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      'We sent a 6-digit code to',
                      textAlign: TextAlign.center,
                      style: AppText.subtitle.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.emailAddress,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'SFPro',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryMaroon,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // OTP Input Fields — uses LayoutBuilder to avoid overflow
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;
                        final fieldWidth = ((maxWidth - 40) / 6).clamp(
                          36.0,
                          50.0,
                        );
                        final fieldHeight = fieldWidth * 1.2;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: fieldWidth,
                              height: fieldHeight,
                              child: TextField(
                                controller: _otpControllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                cursorColor: AppColors.primaryMaroon,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: TextStyle(
                                  fontSize: fieldWidth * 0.45,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkCharcoal,
                                  fontFamily: 'SFPro',
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 5) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                  // Auto-submit when all fields are filled
                                  if (value.isNotEmpty && index == 5) {
                                    FocusScope.of(context).unfocus();
                                    final otp = _getOTP();
                                    if (otp.length == 6) {
                                      _verifyOTP(otp);
                                    }
                                  }
                                },
                                decoration: InputDecoration(
                                  counterText: '',
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: AppColors.textLight.withOpacity(
                                        0.3,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: AppColors.textLight.withOpacity(
                                        0.3,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
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
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final isLoading = ref.watch(isLoadingStateProvider);
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryMaroon,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed:
                                isLoading
                                    ? null
                                    : () {
                                      String otp = _getOTP();
                                      if (otp.length == 6) {
                                        _verifyOTP(otp);
                                      } else {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                'Please enter the complete 6-digit code',
                                              ),
                                              backgroundColor:
                                                  AppColors.warning,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                            child:
                                isLoading
                                    ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      'Verify Code',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'SFPro',
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Resend section
                    Consumer(
                      builder: (context, ref, child) {
                        final isResendLoading = ref.watch(
                          isResendLoadingStateProvider,
                        );
                        return Column(
                          children: [
                            Text(
                              "Didn't receive the code?",
                              style: AppText.small.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: isResendLoading ? null : _resendOTP,
                              child:
                                  isResendLoading
                                      ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.primaryMaroon,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        'Resend Code',
                                        style: AppText.link.copyWith(
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              AppColors.primaryMaroon,
                                        ),
                                      ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
