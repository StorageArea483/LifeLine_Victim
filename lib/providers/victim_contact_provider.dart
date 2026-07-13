import 'package:flutter_riverpod/legacy.dart';

final victimContactLoadingProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

final assignedRescuerProvider =
    StateProvider.autoDispose<Map<String, dynamic>?>((ref) => null);

final assignedNgoProvider = StateProvider.autoDispose<Map<String, dynamic>?>(
  (ref) => null,
);
