import 'package:flutter/material.dart';
import 'package:life_line/pages/chat_bot.dart';
import 'package:life_line/pages/landing_page.dart';
import 'package:life_line/styles/styles.dart';
import 'package:life_line/widgets/features/maps_module/share_location.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNavbar({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) {
          return;
        } else if (index == 0 && context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LandingPage()),
          );
        } else if (index == 1 && context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ShareLocation()),
          );
        } else if (index == 2 && context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ChatBot(request: 'Medical'),
            ),
          );
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.primaryMaroon,
      unselectedItemColor: AppColors.textSecondary,
      elevation: 4,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'Chatbot',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
