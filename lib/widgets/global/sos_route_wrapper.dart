import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/widgets/global/maintenance_route_wrapper.dart';
import 'package:life_line/pages/sos_alternative.dart';
import 'package:life_line/providers/admin_settings_provider.dart';
import 'package:life_line/styles/styles.dart';

class SosRouteWrapper extends ConsumerWidget {
  const SosRouteWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!context.mounted) return const SizedBox.shrink();
    final settings = ref.watch(adminSettingsStreamProvider);

    return settings.when(
      data: (s) {
        return s.sosDisabled
            ? const SosAlternative()
            : const MaintenanceRouteWrapper();
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
              const MaintenanceRouteWrapper(), // Default to MaintenanceRouteWrapper on error
    );
  }
}
