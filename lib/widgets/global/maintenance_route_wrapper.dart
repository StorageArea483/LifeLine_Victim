import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/pages/landing_page.dart';
import 'package:life_line/pages/maintenance_page.dart';
import 'package:life_line/providers/admin_settings_provider.dart';
import 'package:life_line/styles/styles.dart';

class MaintenanceRouteWrapper extends ConsumerWidget {
  const MaintenanceRouteWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!context.mounted) return const SizedBox.shrink();
    final settings = ref.watch(adminSettingsStreamProvider);

    return settings.when(
      data: (s) {
        return s.maintenance ? const MaintenancePage() : const LandingPage();
      },
      loading:
          () => const Scaffold(
            backgroundColor: AppColors.softBackground,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryMaroon),
            ),
          ),
      error:
          (error, stack) =>
              const LandingPage(), // Default to LandingPage on error
    );
  }
}
