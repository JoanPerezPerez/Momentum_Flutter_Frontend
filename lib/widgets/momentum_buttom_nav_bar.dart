// lib/widgets/momentum_bottom_nav_bar.dart
/*import 'package:flutter/material.dart';
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
            Get.offAllNamed('/calendar');
            break;
          case 1:
            Get.offAllNamed('/chatList');
            break;
          case 2:
            Get.offAllNamed('/profile');
            break;
          case 3:
            Get.offAllNamed('/map');
            break;
          case 4:
            Get.offAllNamed('/cataleg');
            break;
          case 5:
            Get.offAllNamed('/optimization');
            break;
          default:
            Get.offAllNamed('/calendar');
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
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology),
          label: 'Optimization',
        ),
      ],
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/navigator_controller.dart';

class MomentumBottomNavBar extends StatelessWidget {
  const MomentumBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavigationController>();

    return Obx(() => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.blue.withAlpha(160),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          currentIndex: navController.selectedIndex.value,
          onTap: (index) {
            navController.selectedIndex.value = index;
            switch (index) {
              case 0:
                Get.offAllNamed('/calendar');
                break;
              case 1:
                Get.offAllNamed('/chatList');
                break;
              case 2:
                Get.offAllNamed('/profile');
                break;
              case 3:
                Get.offAllNamed('/map');
                break;
              case 4:
                Get.offAllNamed('/cataleg');
                break;
              case 5:
                Get.offAllNamed('/optimization');
                break;
              default:
                Get.offAllNamed('/calendar');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Catàleg'),
            BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'Optimization'),
          ],
        ));
  }
}
