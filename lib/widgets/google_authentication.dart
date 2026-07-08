import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_victim/pages/landing_page.dart';
import 'package:life_line_victim/providers/global_state_providers.dart';
import 'package:life_line_victim/services/auth_service.dart';
import 'package:life_line_victim/styles/styles.dart';
import 'package:life_line_victim/widgets/global/page_message.dart';
import 'package:life_line_victim/widgets/global/page_navigation.dart';

class GoogleAuthentication extends StatelessWidget {
  final WidgetRef ref;
  const GoogleAuthentication(this.ref, {super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(globalStateProvider.select((v) => v.isLoading));
    return ElevatedButton(
      onPressed: isLoading ? null : () => _handleGoogleSignIn(context, ref),
      style: AppButtons.dialogAgree,
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
    if (context.mounted) {
      ref.read(globalStateProvider.notifier).setLoading(true);
    }

    try {
      final userCredential = await GoogleSignInService.signInWithGoogle();

      if (userCredential != null) {
        if (context.mounted) {
          pageNavigation(const LandingPage(), context);
        }
      }
      if (context.mounted) {
        ref.read(globalStateProvider.notifier).setLoading(true);
      }
    } catch (e) {
      if (context.mounted) {
        ref.read(globalStateProvider.notifier).setLoading(false);
        pageMessage('Request not completed', context, AppColors.error);
      }
    }
  }
}
