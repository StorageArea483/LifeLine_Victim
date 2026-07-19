import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:life_line_victim/providers/admin_settings_provider.dart';
import 'package:life_line_victim/providers/internet_provider.dart';
import 'package:life_line_victim/providers/request_status_provider.dart';
import 'package:life_line_victim/providers/user_status_provider.dart';

enum AppRoute {
  loading,
  offline,
  login,
  blocked,
  maintenance,
  sosDisabled,
  victimWaiting,
  home,
}

final appRouterProvider = Provider<AppRoute>((ref) {
  final internet = ref.watch(internetProvider);
  final userStatus = ref.watch(userStatusStreamProvider);
  final settings = ref.watch(adminSettingsStreamProvider);
  final requestExists = ref.watch(requestExistsStreamProvider);

  // Loading Screen Fallback
  if (internet.isLoading ||
      userStatus.isLoading ||
      settings.isLoading ||
      requestExists.isLoading) {
    return AppRoute.loading;
  }

  // Network Check
  final connectivity = internet.value;
  if (connectivity == null || connectivity.contains(ConnectivityResult.none)) {
    return AppRoute.offline;
  }

  // Identity Profiles Checks
  final status = userStatus.value;
  if (status == null) return AppRoute.login;
  if (status.isBlocked) return AppRoute.blocked;

  // Remote Config Flags
  final admin = settings.value;
  if (admin == null) return AppRoute.loading;
  if (admin.maintenance) return AppRoute.maintenance;
  if (admin.sosDisabled) return AppRoute.sosDisabled;

  if (requestExists.value == true) {
    return AppRoute.victimWaiting;
  }

  return AppRoute.home;
});

final requestTypeProvider = StateProvider.autoDispose<String>((ref) => '');
