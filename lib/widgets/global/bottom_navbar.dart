import 'package:flutter/material.dart';
import 'package:life_line_victim/pages/chat_bot.dart';
import 'package:life_line_victim/pages/landing_page.dart';
import 'package:life_line_victim/pages/victim_map_page.dart';
import 'package:life_line_victim/styles/styles.dart';
import 'package:life_line_victim/widgets/global/page_navigation.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) {
          return;
        } else if (index == 0 && context.mounted) {
          pageNavigation(const LandingPage(), context);
        } else if (index == 1 && context.mounted) {
          pageNavigation(const VictimMapPage(), context);
        } else if (index == 2 && context.mounted) {
          pageNavigation(const ChatBot(request: 'medical'), context);
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
          icon: Icon(Icons.chat_sharp),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'Chat',
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
