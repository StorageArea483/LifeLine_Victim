import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/pages/google_signup.dart';
import 'package:life_line/providers/auth_provider.dart';
import 'package:life_line/providers/user_status_provider.dart';
import 'package:life_line/styles/styles.dart';
import 'package:life_line/widgets/global/blocked_user_wrapper.dart';
import 'package:life_line/widgets/internet_connection.dart';
import 'package:life_line/widgets/global/sos_route_wrapper.dart';

class CheckConnection extends ConsumerWidget {
  const CheckConnection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!context.mounted) return const SizedBox.shrink();
    final authAsync = ref.watch(authStateProvider);
    return authAsync.when(
      loading: () => _loadingScreen(),
      error: (_, __) => const InternetConnection(child: GoogleSignup()),
      data: (user) {
        if (user == null) {
          return const InternetConnection(child: GoogleSignup());
        }

        if (!context.mounted) return const SizedBox.shrink();
        final userStatusAsync = ref.watch(userStatusStreamProvider);
        return userStatusAsync.when(
          loading: () => _loadingScreen(),
          error:
              (_, __) => const InternetConnection(
                child: BlockedUserWrapper(child: SosRouteWrapper()),
              ),
          data: (userStatus) {
            if (userStatus == null) {
              return const InternetConnection(
                child: BlockedUserWrapper(child: SosRouteWrapper()),
              );
            }
            if (userStatus.isDeleted) return const GoogleSignup();

            // BlockedUserWrapper will handle showing dialog if user is blocked
            return const InternetConnection(
              child: BlockedUserWrapper(child: SosRouteWrapper()),
            );
          },
        );
      },
    );
  }

  Widget _loadingScreen() {
    return Scaffold(
      body: Container(
        decoration: AppContainers.pageContainer,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryMaroon),
        ),
      ),
    );
  }
}
