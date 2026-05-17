import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line/providers/user_status_provider.dart';
import 'package:life_line/widgets/global/victim_blocked_dialog.dart';

class BlockedUserWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const BlockedUserWrapper({super.key, required this.child});

  @override
  ConsumerState<BlockedUserWrapper> createState() => _BlockedUserWrapperState();
}

class _BlockedUserWrapperState extends ConsumerState<BlockedUserWrapper> {
  bool _isDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    if (!mounted) return const SizedBox.shrink();
    final userStatusAsync = ref.watch(userStatusStreamProvider);

    return userStatusAsync.when(
      data: (userStatus) {
        if (userStatus != null && userStatus.isBlocked) {
          // Show dialog if user is blocked
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isDialogShowing && context.mounted) {
              _isDialogShowing = true;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) =>
                        VictimBlockedDialog(userEmail: userStatus.email),
              ).then((_) {
                _isDialogShowing = false;
              });
            }
          });
        } else {
          // Dismiss dialog if user is no longer blocked
          if (_isDialogShowing && context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            _isDialogShowing = false;
          }
        }

        return widget.child;
      },
      loading: () => widget.child,
      error: (_, __) => widget.child,
    );
  }
}
