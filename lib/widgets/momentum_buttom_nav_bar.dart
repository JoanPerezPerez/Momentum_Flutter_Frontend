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
      currentIndex: selectedIndex,
      onTap: (index) {
        onItemTapped(index);
        switch (index) {
          case 0:
            Get.toNamed('/calendar');
            break;
          case 1:
            Get.snackbar("Chats", "Ruta no implementada");
            break;
          case 2:
            Get.snackbar("Cuenta", "Ruta no implementada");
            break;
          case 3:
            Get.snackbar("Configuración", "Ruta no implementada");
            break;
          case 4:
            Get.toNamed('/cataleg');
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
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Cataleg'),
      ],
    );
  }
}
