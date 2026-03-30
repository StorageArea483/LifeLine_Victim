import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/pages/landing_page.dart';
import 'package:life_line/providers/loading_state_provider.dart';
import 'package:life_line/services/auth_service.dart';
import 'package:life_line/styles/styles.dart';
import 'package:life_line/widgets/internet_connection.dart';

class GoogleAuthentication extends StatelessWidget {
  final WidgetRef ref;
  const GoogleAuthentication(this.ref, {super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingStateProvider);
    return ElevatedButton(
      onPressed: isLoading ? null : () => _handleGoogleSignIn(context, ref),
      style: AppButtons.primary,
      child:
          isLoading
              ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppColors.primaryMaroon,
                ),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google_logo.webp',
                    height: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.hub_outlined,
                        size: 80,
                        color: AppColors.primaryMaroon,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text('Continue with Google'),
                ],
              ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    final loadingNotifier = ref.read(isLoadingStateProvider.notifier);

    loadingNotifier.state = true;

    try {
      final userCredential = await GoogleSignInService.signInWithGoogle();

      if (userCredential != null) {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) => const InternetConnection(child: LandingPage()),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        loadingNotifier.state = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request not completed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
