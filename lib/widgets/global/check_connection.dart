import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:life_line/pages/google_signup.dart';
import 'package:life_line/pages/landing_page.dart';
import 'package:life_line/styles/styles.dart';
import 'package:life_line/widgets/global/victim_blocked.dart';
import 'package:life_line/widgets/internet_connection.dart';

class CheckConnection extends StatelessWidget {
  const CheckConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _loadingScreen();
        }

        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const InternetConnection(child: GoogleSignup());
        }

        final String uid = authSnapshot.data!.uid;
        final String email = authSnapshot.data!.email ?? '';

        return StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
          builder: (context, firestoreSnapshot) {
            if (firestoreSnapshot.connectionState == ConnectionState.waiting) {
              return _loadingScreen();
            }

            if (firestoreSnapshot.hasError ||
                !firestoreSnapshot.hasData ||
                !firestoreSnapshot.data!.exists) {
              return const InternetConnection(child: LandingPage());
            }

            final userData =
                firestoreSnapshot.data!.data() as Map<String, dynamic>;
            final bool isBlocked = userData['blocked'] ?? false;

            if (isBlocked) {
              return InternetConnection(child: VictimBlocked(userEmail: email));
            }

            return const InternetConnection(child: LandingPage());
          },
        );
      },
    );
  }

  Widget _loadingScreen() {
    return Scaffold(
      body: Container(
        decoration: AppContainers.pageContainer,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryMaroon),
        ),
      ),
    );
  }
}
