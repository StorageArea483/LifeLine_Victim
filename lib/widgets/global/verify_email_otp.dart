import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:life_line/services/functions/transitions_in_pages.dart';
import 'package:life_line/utils/styles.dart';
import 'package:life_line/widgets/features/victim_authentication/sign_up/victim_signup.dart';
import 'package:life_line/widgets/features/victim_dashboard/victim_page.dart';
import 'package:life_line/widgets/features/victim_authentication/login/change_password.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class VerifyEmailOtp extends StatefulWidget {
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
  State<VerifyEmailOtp> createState() => _VerifyEmailOtpState();
}

class _VerifyEmailOtpState extends State<VerifyEmailOtp> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  // Gmail SMTP credentials (use env/secure storage in production)
  static const String _senderEmail = 'sajidaryan378@gmail.com';
  // Google app passwords are shown with spaces; remove spaces when using
  static const String _appPassword = 'whrizhmeuxpwokma';

  // Generated OTP stored in memory for simple verification
  String? _generatedOtp;

  bool _isLoading = false;
  bool _isResendLoading = false;

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
    msg.from = Address(_senderEmail, 'LifeLine');
    msg.recipients = [to];
    msg.subject = 'Your LifeLine verification code';
    msg.text = 'Your verification code is: $code\nThis code will expire soon.';
    return msg;
  }

  // Send OTP via Gmail SMTP using mailer
  Future<void> _sendOTP() async {
    setState(() => _isLoading = true);

    try {
      _generatedOtp = _generateOtp();

      final smtpServer = gmail(_senderEmail, _appPassword);
      final message = _createOtpMessage(widget.emailAddress, _generatedOtp!);

      await send(message, smtpServer);

      setState(() => _isLoading = false);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully to your email!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Verify OTP by comparing with the generated code
  Future<void> _verifyOTP(String otp) async {
    setState(() => _isLoading = true);

    final bool isValid = _generatedOtp != null && otp == _generatedOtp;

    if (!isValid) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // OTP verified
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email verified successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

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

        setState(() => _isLoading = false);

        // Navigate to VictimPage
        // ignore: use_build_context_synchronously
        pageTransition(context, const VictimPage());
      } else if (!widget.isSignUp && widget.isLogin) {
        setState(() => _isLoading = false);

        // User is resetting password - navigate to ChangePassword
        // ignore: use_build_context_synchronously
        pageTransition(
          context,
          ChangePassword(emailAddress: widget.emailAddress),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete operation: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  // Resend OTP: regenerate and email again
  Future<void> _resendOTP() async {
    setState(() => _isResendLoading = true);

    try {
      _generatedOtp = _generateOtp();

      final smtpServer = gmail(_senderEmail, _appPassword);
      final message = _createOtpMessage(widget.emailAddress, _generatedOtp!);

      await send(message, smtpServer);

      setState(() => _isResendLoading = false);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully to your email!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isResendLoading = false);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resending OTP: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getOTP() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 24,
                ),
                onPressed: () => pageTransition(context, VictimSignup()),
              ),

              const SizedBox(height: AppSpacing.xl),

              const Text(
                'User Account Verification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              const Text(
                'Enter the code',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                'We sent a verification code to ${widget.emailAddress}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromRGBO(158, 158, 158, 1),
                ),
              ),

              const SizedBox(height: AppSpacing.xxxxl),

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
                      cursorColor: Colors.blue,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.blue,
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

              const SizedBox(height: AppSpacing.xxxxl),

              Center(
                child: Column(
                  children: [
                    const Text(
                      "Didn't receive the code?",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GestureDetector(
                      onTap: _isResendLoading ? null : _resendOTP,
                      child:
                          _isResendLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                              )
                              : const Text(
                                'Resend Code',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80), // ✅ Replaced Spacer()

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            String otp = _getOTP();
                            if (otp.length == 6) {
                              _verifyOTP(otp);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter the complete 6-digit OTP',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Verify',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
