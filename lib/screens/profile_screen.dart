/* import 'package:flutter/material.dart';
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
*/

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
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Obx(
          () => Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Perfil d\'usuari',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            user.value.name.isNotEmpty
                                ? user.value.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.value.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${user.value.age} anys',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.value.mail,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                // Aquí poses la navegació o acció de configuració
                                Get.toNamed(
                                  '/settings',
                                ); // O el que facis servir per navegar
                              },
                              icon: const Icon(Icons.settings),
                              label: const Text('Configuració'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                authController.logout();
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text('Tanca sessió'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Get.toNamed('/friends'); 
                              },
                              icon: const Icon(Icons.group),
                              label: const Text('Amistats'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: MomentumBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/widgets/momentum_buttom_nav_bar.dart';
import 'package:momentum/widgets/profile_title.dart';
import 'package:momentum/widgets/profile_card.dart';
import 'package:momentum/controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  final controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 40),
              ProfileTitle(),
              SizedBox(height: 20),
              ProfileCard(),
              SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                    TabBar(
                      controller: controller.tabController,
                      tabs: const [
                        Tab(text: 'Usuaris'),
                        Tab(text: 'Sol·licituds'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: controller.tabController,
                        children: [
                          Obx(() => ListView(
                            children: controller.allUsers
                                .where((u) => u['_id'] != controller.userId)
                                .map((user) => ListTile(
                                      title: Text(user['mail'] ?? ''),
                                      trailing: IconButton(
                                        icon: Icon(Icons.person_add),
                                        onPressed: () => controller.sendRequest(user['_id']),
                                      ),
                                    ))
                                .toList(),
                          )),
                          Obx(() => ListView(
                            children: controller.pendingRequests
                                .map((user) => ListTile(
                                      title: Text(user['mail'] ?? ''),
                                      trailing: IconButton(
                                        icon: Icon(Icons.check),
                                        onPressed: () => controller.acceptRequest(user['_id']),
                                      ),
                                    ))
                                .toList(),
                          )),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() => MomentumBottomNavBar(
            selectedIndex: controller.selectedIndex.value,
            onItemTapped: (index) => controller.selectedIndex.value = index,
          )),
    );
  }
}*/