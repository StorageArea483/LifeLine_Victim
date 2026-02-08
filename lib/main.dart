import 'package:flutter/material.dart';
import 'package:life_line/firebase_options.dart';
import 'package:life_line/widgets/constants/constants.dart';
import 'package:life_line/widgets/global/role_select_screen.dart';
import 'package:life_line/widgets/global/victim_blocked.dart';
import 'package:life_line/widgets/features/victim_dashboard/victim_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthCheckScreen(),
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userEmail = prefs.getString('userEmail');

    if (userEmail == null || userEmail.isEmpty) {
      _navigateToScreen(const RoleSelectScreen());
      return;
    }

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('victim-info-database')
              .where('emailAddress', isEqualTo: userEmail)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        final bool isBlocked = userData['blocked'] ?? false;
        if (isBlocked) {
          _navigateToScreen(VictimBlocked(userEmail: userEmail));
        } else {
          _navigateToScreen(const VictimPage());
        }
      } else {
        _navigateToScreen(const RoleSelectScreen());
      }
    } catch (e) {
      _navigateToScreen(const RoleSelectScreen());
    }
  }

  void _navigateToScreen(Widget screen) {
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => screen));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primaryMaroon),
      ),
    );
  }
}
