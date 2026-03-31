import 'package:flutter_riverpod/legacy.dart';

final isLoadingStateProvider = StateProvider.autoDispose<bool>((ref) => false);

final isResendLoadingStateProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);
