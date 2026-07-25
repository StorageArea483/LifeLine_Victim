import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:life_line_victim/providers/admin_settings_provider.dart';
import 'package:life_line_victim/providers/request_status_provider.dart';
import 'package:life_line_victim/providers/user_status_provider.dart';

enum AppRoute {
  loading,
  login,
  blocked,
  maintenance,
  sosDisabled,
  victimWaiting,
  home,
}

final appRouterProvider = Provider<AppRoute>((ref) {
  final userStatus = ref.watch(userStatusStreamProvider);
  final settings = ref.watch(adminSettingsStreamProvider);
  final requestStatus = ref.watch(
    requestStatusStreamProvider,
  ); // Watched the updated provider

  // Identity Profiles Checks
  final status = userStatus.value;
  if (status == null) return AppRoute.login;
  if (status.isBlocked) return AppRoute.blocked;

  // Remote Config Flags
  final admin = settings.value;
  if (admin == null) return AppRoute.loading;
  if (admin.maintenance) return AppRoute.maintenance;
  if (admin.sosDisabled) return AppRoute.sosDisabled;

  // Check the requestAccepted value
  final requestStatusValue = requestStatus.value;
  if (requestStatusValue == 'pending' || requestStatusValue == 'rejected') {
    return AppRoute.victimWaiting;
  } else if (requestStatusValue == 'accepted') {
    return AppRoute.home;
  }

  return AppRoute.home;
});

final requestTypeProvider = StateProvider.autoDispose<String>((ref) => '');
