import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeverityService {
  static String compareSeverities({
    required String? initialSeverity,
    required String? chatbotSeverity,
  }) {
    final initial = initialSeverity ?? '';
    final chatbot = chatbotSeverity ?? '';

    // if either is High Risk, return High Risk
    if (initial == 'High Risk' || chatbot == 'High Risk') {
      return 'High Risk';
    }

    // If either is Medium Risk, return Medium Risk
    if (initial == 'Medium Risk' || chatbot == 'Medium Risk') {
      return 'Medium Risk';
    }

    // If either is Low Risk, return Low Risk
    if (initial == 'Low Risk' || chatbot == 'Low Risk') {
      return 'Low Risk';
    }

    // Default to initial severity or Unknown
    return initial.isNotEmpty ? initial : 'Unknown';
  }

  static String? extractSeverityFromConversation(
    List<Map<String, String>> conversationHistory,
  ) {
    final lastAssistant =
        conversationHistory.lastWhere(
          (msg) => msg['role'] == 'assistant',
          orElse: () => {},
        )['content'] ??
        '';

    if (lastAssistant.contains('High Risk')) return 'High Risk';
    if (lastAssistant.contains('Medium Risk')) return 'Medium Risk';
    if (lastAssistant.contains('Low Risk')) return 'Low Risk';

    return null;
  }

  static Future<void> updateUserSeverity(String severity) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No authenticated user');

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'severity': severity},
      );
    } catch (e) {
      rethrow;
    }
  }
}
