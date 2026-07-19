import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_victim/pages/google_signup.dart';
import 'package:life_line_victim/pages/landing_page.dart';
import 'package:life_line_victim/pages/maintenance_page.dart';
import 'package:life_line_victim/pages/offline_connectivity.dart';
import 'package:life_line_victim/pages/sos_alternative.dart';
import 'package:life_line_victim/pages/victim_waiting_screen.dart';
import 'package:life_line_victim/providers/app_router_provider.dart';
import 'package:life_line_victim/styles/styles.dart';
import 'package:life_line_victim/pages/victim_blocked_dialog.dart';
import 'package:life_line_victim/widgets/global/in_out_calls.dart';

class CheckConnection extends ConsumerWidget {
  const CheckConnection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(appRouterProvider);

    switch (route) {
      case AppRoute.loading:
        return Scaffold(
          body: Container(
            decoration: AppContainers.pageContainer,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryMaroon),
            ),
          ),
        );
      case AppRoute.offline:
        return const OfflineConnectivity();
      case AppRoute.login:
        return const GoogleSignup();
      case AppRoute.blocked:
        final user = FirebaseAuth.instance.currentUser;
        return VictimBlockedDialog(email: user?.email ?? '');
      case AppRoute.maintenance:
        return const MaintenancePage();
      case AppRoute.sosDisabled:
        return const InOutCalls(child: SosAlternative());
      case AppRoute.victimWaiting:
        return Consumer(
          builder: (context, ref, child) {
            final requestType = ref.watch(requestTypeProvider);
            return VictimWaitingScreen(requestType: requestType);
          },
        );
      case AppRoute.home:
        return const InOutCalls(child: LandingPage());
    }
  }
}
