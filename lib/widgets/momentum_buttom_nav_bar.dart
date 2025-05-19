// lib/widgets/momentum_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MomentumBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const MomentumBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white, 
      selectedItemColor: Colors.blue, 
      unselectedItemColor: Colors.blue.withAlpha(160), 
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), 
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      currentIndex: selectedIndex,
      onTap: (index) {
        onItemTapped(index);
        switch (index) {
          case 0:
            Get.toNamed('/calendar');
            break;
          case 1:
            Get.toNamed('/chatList');
            break;
          case 2:
            Get.toNamed('/profile');
            break;
          case 3:
            Get.toNamed('/map');
            break;
          case 4:
            Get.toNamed('/cataleg');
            break;
          default:
            Get.toNamed('/calendar');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Cataleg'),
      ],
    );
  }
}
