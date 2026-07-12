import 'package:flutter_riverpod/legacy.dart';

// Deterministic chat id between victim and rescuer
final victimChatIdProvider = StateProvider<String?>((ref) => null);

// Loading state while chat initializes
final victimChatLoadingProvider = StateProvider<bool>((ref) => false);

// Messages for a given chatId (kept generic as Map since no Message model
// exists yet in this project — swap for a typed model later if you add one)
final victimChatMessagesProvider =
    StateProvider.family<List<Map<String, dynamic>>, String>(
      (ref, chatId) => [],
    );

// Live online/offline status of the rescuer, keyed by rescuerId
final rescuerOnlineStatusProvider = StateProvider.family<bool, String>(
  (ref, rescuerId) => false,
);
