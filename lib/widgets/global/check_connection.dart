import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/pages/google_signup.dart';
import 'package:life_line/providers/user_status_provider.dart';
import 'package:life_line/styles/styles.dart';
import 'package:life_line/widgets/global/victim_blocked.dart';
import 'package:life_line/widgets/internet_connection.dart';
import 'package:life_line/widgets/global/sos_route_wrapper.dart';

class CheckConnection extends ConsumerWidget {
  const CheckConnection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _loadingScreen();
        }

        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const InternetConnection(child: GoogleSignup());
        }

        if (!context.mounted) return const SizedBox.shrink();
        // User is authenticated, now check their blocked/deleted status
        final userStatusAsync = ref.watch(userStatusStreamProvider);

        return userStatusAsync.when(
          // Loading state - show loading screen
          loading: () => _loadingScreen(),

          // Error state - allow access (fail open for better UX)
          error:
              (error, stack) =>
                  const InternetConnection(child: SosRouteWrapper()),

          // Data received - check if user is blocked or deleted
          data: (userStatus) {
            if (userStatus == null) {
              // No user status available, allow access
              return const InternetConnection(child: SosRouteWrapper());
            }

            if (userStatus.isDeleted) {
              return const GoogleSignup();
            }

            if (userStatus.isBlocked) {
              return InternetConnection(
                child: VictimBlocked(userEmail: userStatus.email),
              );
            }

            // User is not blocked or deleted, allow access
            return const InternetConnection(child: SosRouteWrapper());
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
