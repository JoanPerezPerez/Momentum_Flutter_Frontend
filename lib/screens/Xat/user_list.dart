import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/xat_controller.dart';
import 'package:momentum/routes/app_routes.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/widgets/momentum_buttom_nav_bar.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  int _selectedIndex = 0;
  final XatController xatController = Get.find<XatController>();
  final AuthController authController = Get.find<AuthController>();
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authController.selectedRole.value == "user") {
        xatController.getUserWithWhomUserChatted();
        currentUserId = authController.currentUser.value.id as String;
      } else if (authController.selectedRole.value == "worker") {
        xatController.getUserWithWhomWorkerChatted();
        currentUserId = authController.currentWorker.value.id as String;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Xats',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white), 
      ),
      body: Obx(() {
        if (xatController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final users = xatController.users;

        // Agrupar usuaris per rol
        Map<String, List<List<dynamic>>> groupedUsers = {
          'user': [],
          'worker': [],
          'location': [],
          'business': [],
        };

        for (var user in users) {
          if (user.length >= 3 && groupedUsers.containsKey(user[2])) {
            groupedUsers[user[2]]!.add(user);
          }
        }

        // Crear la llista final amb seccions
        final sectionOrder = ['user', 'worker', 'location', 'business'];
        final sectionTitles = {
          'user': 'USERS:',
          'worker': 'WORKERS:',
          'location': 'LOCATIONS:',
          'business': 'BUSINESSES:',
        };

        final List<Widget> listItems = [];

        for (String role in sectionOrder) {
          final group = groupedUsers[role]!;
          if (group.isEmpty) continue;

          // Capçalera de secció
          listItems.add(
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Text(
                sectionTitles[role]!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
          );

          // Usuaris de la secció
          for (var user in group) {
            final userName = user[0];
            final userId = user[1];
            final myType = user[2];
            final myId = user[3];
            final userType = getUserRoleById(userId);
            listItems.add(
              ListTile(
                leading: Icon(Icons.person),
                title: Text(userName),
                onTap: () async {
                  try {
                    xatController.chatId.value = '';
                    xatController.chatMessages.clear();
                    await xatController.getChatId(myId, userId, myType);
                    xatController.myChatType.value = myType;
                    final chatId = xatController.chatId.value;
                    if (!mounted) return;
                    if (chatId.isEmpty) {
                      Get.snackbar("Error", "Chat ID is empty");
                      return;
                    }
                    await xatController.setChatId(chatId);
                    await xatController.setOtherUser(
                      userName,
                      userId,
                      userType,
                    );
                    Get.toNamed(AppRoutes.xat);
                  } catch (e) {
                    if (mounted) {
                      Get.snackbar(
                        "Error",
                        "Failed to get chat id: ${e.toString()}",
                      );
                    }
                  }
                },
              ),
            );
          }
        }

        return ListView(children: listItems);
      }),
      bottomNavigationBar: const MomentumBottomNavBar(),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String getUserRoleById(String userId) {
    final groupedUsers = {
      'user':
          xatController.users
              .where((u) => u.length >= 3 && u[2] == 'user')
              .toList(),
      'worker':
          xatController.users
              .where((u) => u.length >= 3 && u[2] == 'worker')
              .toList(),
      'location':
          xatController.users
              .where((u) => u.length >= 3 && u[2] == 'location')
              .toList(),
      'business':
          xatController.users
              .where((u) => u.length >= 3 && u[2] == 'business')
              .toList(),
    };

    for (var entry in groupedUsers.entries) {
      for (var user in entry.value) {
        if (user[1] == userId) {
          return entry.key; // Retorna el rol: 'user', 'worker', etc.
        }
      }
    }

    return 'unknown'; // Per si no es troba cap coincidència
  }
}
