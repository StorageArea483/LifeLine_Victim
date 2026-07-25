import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_victim/pages/landing_page.dart';
import 'package:life_line_victim/pages/victim_contact_page.dart';
import 'package:life_line_victim/providers/victim_chat_provider.dart';
import 'package:life_line_victim/styles/styles.dart';
import 'package:life_line_victim/utils/responsive_helper.dart';
import 'package:life_line_victim/widgets/global/in_out_calls.dart';
import 'package:life_line_victim/widgets/global/internet_connection.dart';
import 'package:life_line_victim/widgets/global/page_message.dart';
import 'package:life_line_victim/widgets/global/page_navigation.dart';
import 'dart:io' show Platform;

import 'package:life_line_victim/widgets/global/victim_online_status.dart';

class VictimChatScreen extends ConsumerStatefulWidget {
  final String rescuerId;
  final String rescuerName;
  final String rescuerPhotoUrl;

  const VictimChatScreen({
    super.key,
    required this.rescuerId,
    required this.rescuerName,
    required this.rescuerPhotoUrl,
  });

  @override
  ConsumerState<VictimChatScreen> createState() => _VictimChatScreenState();
}

class _VictimChatScreenState extends ConsumerState<VictimChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  FirebaseFirestore? rescuerFirestore;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _presenceSubscription;

  String? currentUserId;
  String? chatId;

  // life-line-rescuer database credentials
  static const FirebaseOptions _rescuerAndroidOptions = FirebaseOptions(
    apiKey: 'AIzaSyDs-CoAc_fqrB-3BMl4N7pYSavyNV72zUQ',
    appId: '1:494066243537:android:ffdb36137d6d3cb1a4b2f0',
    messagingSenderId: '494066243537',
    projectId: 'life-line-rescuer-b1f1c',
    storageBucket: 'life-line-rescuer-b1f1c.firebasestorage.app',
  );

  static const FirebaseOptions _rescuerIosOptions = FirebaseOptions(
    apiKey: 'AIzaSyA3cUXkIjLsHhTv2l3OKhNzE3EZtejqxLg',
    appId: '1:494066243537:ios:8f122b25432725a6a4b2f0',
    messagingSenderId: '494066243537',
    projectId: 'life-line-rescuer-b1f1c',
    storageBucket: 'life-line-rescuer-b1f1c.firebasestorage.app',
    iosBundleId: 'com.example.lifeLineRescuer',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeChat();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageSubscription?.cancel();
    _presenceSubscription?.cancel();
    super.dispose();
  }

  // Builds a deterministic chat id from the two participant ids
  String _generateChatId(String userId, String rescuerId) {
    final ids = [userId, rescuerId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _initializeChat() async {
    if (mounted) {
      ref.read(victimChatLoadingProvider.notifier).state = true;
    }
    try {
      FirebaseApp rescuerApp;
      try {
        rescuerApp = Firebase.app('life-line-rescuer');
      } catch (_) {
        rescuerApp = await Firebase.initializeApp(
          name: 'life-line-rescuer',
          options: Platform.isIOS ? _rescuerIosOptions : _rescuerAndroidOptions,
        );
      }
      rescuerFirestore = FirebaseFirestore.instanceFor(app: rescuerApp);

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        if (mounted) {
          ref.read(victimChatLoadingProvider.notifier).state = false;
          pageMessage(
            'Unable to load chat. Please re-try.',
            context,
            AppColors.error,
          );
          pageNavigation(
            const InternetConnection(
              child: VictimOnlineStatus(
                child: InOutCalls(child: LandingPage()),
              ),
            ),
            context,
          );
        }
        return;
      }

      currentUserId = userId;

      final chatId = _generateChatId(userId, widget.rescuerId);
      if (mounted) {
        ref.read(victimChatIdProvider.notifier).state = chatId;
      }

      _subscribeToMessages(chatId);
      _subscribeToPresence();

      if (mounted) {
        ref.read(victimChatLoadingProvider.notifier).state = false;
      }
    } catch (e) {
      if (mounted) {
        ref.read(victimChatLoadingProvider.notifier).state = false;
        pageMessage(
          'An unexpected error occurred. Please try again.',
          context,
          AppColors.error,
        );
        pageNavigation(
          const InternetConnection(
            child: VictimOnlineStatus(child: InOutCalls(child: LandingPage())),
          ),
          context,
        );
      }
    }
  }

  void _subscribeToMessages(String chatId) {
    if (rescuerFirestore == null) return;

    try {
      _messageSubscription?.cancel();

      _messageSubscription = rescuerFirestore!
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
            if (!mounted) return;

            final messages =
                snapshot.docs.map((doc) {
                  final data = doc.data();
                  return {
                    'id': doc.id,
                    'senderId': data['senderId'] ?? '',
                    'text': data['text'] ?? '',
                    'createdAt': data['createdAt'],
                  };
                }).toList();

            if (!mounted) return;
            ref.read(victimChatMessagesProvider(chatId).notifier).state =
                messages;
          });
    } catch (e) {
      if (mounted) {
        pageMessage(
          'Unable to load messages, please retry',
          context,
          AppColors.error,
        );
      }
    }
  }

  void _subscribeToPresence() {
    if (rescuerFirestore == null) return;

    try {
      _presenceSubscription?.cancel();

      _presenceSubscription = rescuerFirestore!
          .collection('users')
          .doc(widget.rescuerId)
          .snapshots()
          .listen((snapshot) {
            if (!mounted) return;
            final isOnline = snapshot.data()?['online'] ?? false;
            ref
                .read(rescuerOnlineStatusProvider(widget.rescuerId).notifier)
                .state = isOnline;
          });
    } catch (e) {
      if (mounted) {
        pageMessage(
          'Unable to check rescuer status, please retry',
          context,
          AppColors.error,
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    try {
      if (rescuerFirestore == null) return;

      final text = _messageController.text.trim();
      if (text.isEmpty) return;

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (!mounted) return;
      final currentChatId = ref.read(victimChatIdProvider);

      if (userId == null || currentChatId == null) {
        if (mounted) {
          pageMessage(
            'Unable to send message. Please try again.',
            context,
            AppColors.error,
          );
        }
        return;
      }

      _messageController.clear();

      await rescuerFirestore!
          .collection('chats')
          .doc(currentChatId)
          .collection('messages')
          .add({
            'chatId': currentChatId,
            'senderId': userId,
            'receiverId': widget.rescuerId,
            'text': text,
            'status': 'sent',
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      if (mounted) {
        pageMessage(
          'Unable to send message. Please try again.',
          context,
          AppColors.error,
        );
      }
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      if (!mounted) return;
      final chatId = ref.read(victimChatIdProvider);
      if (rescuerFirestore == null || chatId == null) return;

      await rescuerFirestore!
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      if (mounted) {
        pageMessage(
          'Unable to delete message. Please try again.',
          context,
          AppColors.error,
        );
      }
    }
  }

  Widget _buildOptionsMenu(String messageId) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        size: 18,
        color: AppColors.textSecondary,
      ),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) {
        if (value == 'delete') {
          _deleteMessage(messageId);
        }
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Message'),
                ],
              ),
            ),
          ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: ResponsiveHelper.contentWidth(context),
            child: Column(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    return _buildHeader(context, ref);
                  },
                ),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      return _buildMessagesList(context, ref);
                    },
                  ),
                ),
                _buildInputSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final avatarSize = ResponsiveHelper.isTablet(context) ? 56.0 : 40.0;
    final isOnline = ref.watch(rescuerOnlineStatusProvider(widget.rescuerId));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.isTablet(context) ? 24 : 16,
        vertical: ResponsiveHelper.isTablet(context) ? 16 : 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: ResponsiveHelper.iconSize(context),
              color: AppColors.textPrimary,
            ),
            onPressed:
                () => pageNavigation(
                  const InternetConnection(
                    child: VictimOnlineStatus(
                      child: InOutCalls(child: VictimContactPage()),
                    ),
                  ),
                  context,
                ),
          ),
          SizedBox(
            width: avatarSize,
            height: avatarSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: avatarSize / 2,
                  backgroundColor: AppColors.primaryMaroon.withOpacity(0.1),
                  backgroundImage:
                      widget.rescuerPhotoUrl.isNotEmpty
                          ? NetworkImage(widget.rescuerPhotoUrl)
                          : null,
                  child:
                      widget.rescuerPhotoUrl.isEmpty
                          ? Icon(
                            Icons.person,
                            color: AppColors.primaryMaroon,
                            size: avatarSize * 0.5,
                          )
                          : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: avatarSize * 0.28,
                    height: avatarSize * 0.28,
                    decoration: BoxDecoration(
                      color: isOnline ? AppColors.success : AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surfaceLight,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: ResponsiveHelper.isTablet(context) ? 16 : 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.rescuerName,
                  style: AppText.fieldLabel.copyWith(
                    fontSize: ResponsiveHelper.isTablet(context) ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkCharcoal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: AppText.small.copyWith(
                    color:
                        isOnline ? AppColors.success : AppColors.textSecondary,
                    fontSize: ResponsiveHelper.bodyFont(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(victimChatLoadingProvider);
    final chatId = ref.watch(victimChatIdProvider);

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryMaroon),
      );
    }

    if (chatId == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryMaroon),
      );
    }

    final messages = ref.watch(victimChatMessagesProvider(chatId));

    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.isTablet(context) ? 48 : 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.textSecondary.withOpacity(0.5),
                size: ResponsiveHelper.isTablet(context) ? 96 : 64,
              ),
              SizedBox(height: ResponsiveHelper.isTablet(context) ? 24 : 16),
              Text(
                'No messages yet',
                style: AppText.subtitle.copyWith(
                  fontSize: ResponsiveHelper.titleFont(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isSentByMe = message['senderId'] == currentUserId;
        return _buildMessageBubble(context, message, isSentByMe);
      },
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    Map<String, dynamic> message,
    bool isSentByMe,
  ) {
    final bubbleMaxWidth = MediaQuery.of(context).size.width * 0.7;
    final messageId = message['id'] as String;

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isSentByMe) _buildOptionsMenu(messageId),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
            decoration: BoxDecoration(
              color: isSentByMe ? AppColors.primaryMaroon : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isSentByMe ? 16 : 4),
                bottomRight: Radius.circular(isSentByMe ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkCharcoal.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message['text'] ?? '',
              style: TextStyle(
                color: isSentByMe ? Colors.white : AppColors.darkCharcoal,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.isTablet(context) ? 24 : 12,
        12,
        ResponsiveHelper.isTablet(context) ? 24 : 12,
        ResponsiveHelper.isTablet(context) ? 24 : 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(top: BorderSide(color: AppColors.borderColor, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.softBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primaryMaroon.withOpacity(0.1),
                ),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  hintStyle: AppText.small.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.primaryMaroon,
            radius: ResponsiveHelper.isTablet(context) ? 26 : 22,
            child: IconButton(
              icon: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: ResponsiveHelper.isTablet(context) ? 22 : 18,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
