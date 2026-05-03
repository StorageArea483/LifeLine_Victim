import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/pages/landing_page.dart';
import 'package:life_line/pages/sos_alternative.dart';
import 'package:life_line/providers/admin_settings_provider.dart';
import 'package:life_line/styles/styles.dart';

class SosRouteWrapper extends ConsumerWidget {
  const SosRouteWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sosDisabledAsync = ref.watch(sosDisabledStreamProvider);

    return sosDisabledAsync.when(
      data: (sosDisabled) {
        return sosDisabled ? const SosAlternative() : const LandingPage();
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
