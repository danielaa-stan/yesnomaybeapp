import 'package:flutter/material.dart';
import '../pages/homepage.dart';
import '../pages/createpollpage.dart';
import '../pages/searchpollpage.dart';
import '../pages/userprofilepage.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const CreatePollPage();
      case 2:
        return const SearchPollPage();
      case 3:
        return const UserProfilePage();
      default:
        return const HomePage();
    }
  }

  Widget _buildNavIcon(BuildContext context, IconData icon, int index) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (currentIndex == index) {
          return;  //do nothing if already on this page
        }

        Navigator.popUntil(context, (route) => route.isFirst);

        if (index != 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => _getPage(index)),
          );
        }
      },
      child: Icon(
        icon,
        size: 32,
        color: isSelected ? const Color(0xFF4EE06D) : Colors.white70,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A4D4D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      // Wrap with SafeArea to handle devices with bottom notches
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIcon(context, Icons.grid_view_rounded, 0),
              _buildNavIcon(context, Icons.add_circle_outline, 1),
              _buildNavIcon(context, Icons.search, 2),
              _buildNavIcon(context, Icons.person_outline, 3),
            ],
          ),
        ),
      ),
    );
  }
}