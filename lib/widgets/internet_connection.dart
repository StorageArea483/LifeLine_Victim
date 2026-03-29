import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/pages/offline_connectivity.dart';
import 'package:life_line/providers/internet_provider.dart';

class InternetConnection extends ConsumerWidget {
  final Widget child;
  const InternetConnection({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(internetProvider);
    return connectionState.when(
      skipLoadingOnRefresh: false,
      skipLoadingOnReload: false,
      data: (connectivityResult) {
        final hasInternet =
            !connectivityResult.contains(ConnectivityResult.none);

        if (hasInternet) {
          return child;
        } else {
          return const OfflineConnectivity();
        }
      },
      loading: () => child,
      error: (_, __) => const OfflineConnectivity(),
    );
  }
}
