import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/widgets/momentum_buttom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  int _selectedIndex = 2; // Índex del perfil

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Benvingut a Momentum',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authController.currentUser.value.name.isNotEmpty
                        ? authController.currentUser.value.name
                        : 'Usuari desconegut',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            )),
      ),
      bottomNavigationBar: MomentumBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
