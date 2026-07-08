import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:life_line_victim/providers/admin_settings_provider.dart';
import 'package:life_line_victim/providers/auth_provider.dart';
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
  final auth = ref.watch(authStateProvider);
  final internet = ref.watch(internetProvider);
  final userStatus = ref.watch(userStatusStreamProvider);
  final settings = ref.watch(adminSettingsStreamProvider);
  final requestExists = ref.watch(requestExistsStreamProvider);

  // Loading
  if (auth.isLoading ||
      internet.isLoading ||
      userStatus.isLoading ||
      settings.isLoading ||
      requestExists.isLoading) {
    return AppRoute.loading;
  }

  // Offline
  final connectivity = internet.value;

  if (connectivity == null || connectivity.contains(ConnectivityResult.none)) {
    return AppRoute.offline;
  }

  // Login
  final user = auth.value;

  if (user == null) {
    return AppRoute.login;
  }

  // User Status
  final status = userStatus.value;

  if (status == null) {
    return AppRoute.login;
  }

  if (status.isBlocked) {
    return AppRoute.blocked;
  }

  // Admin Settings
  final admin = settings.value;

  if (admin == null) {
    return AppRoute.loading;
  }

  if (admin.maintenance) {
    return AppRoute.maintenance;
  }

  if (admin.sosDisabled) {
    return AppRoute.sosDisabled;
  }

  if (requestExists.value == true) {
    return AppRoute.victimWaiting;
  }

  return AppRoute.home;
});

final requestTypeProvider = StateProvider.autoDispose<String>((ref) => '');
