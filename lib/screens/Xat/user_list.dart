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
      xatController.getUserWithWhomUserChatted();
      currentUserId = authController.currentUser.value.id as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Llista d\'usuaris')),
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
                  color: Colors.grey[700],
                ),
              ),
            ),
          );

          // Usuaris de la secció
          for (var user in group) {
            final userName = user[0];
            final userId = user[1];

            listItems.add(
              ListTile(
                title: Text(userName),
                onTap: () async {
                  try {
                    xatController.chatId.value = '';
                    xatController.chatMessages.clear();
                    await xatController.getChatId(currentUserId, userId);
                    final chatId = xatController.chatId.value;
                    if (!mounted) return;
                    if (chatId.isEmpty) {
                      Get.snackbar("Error", "Chat ID is empty");
                      return;
                    }
                    await xatController.setChatId(chatId);
                    await xatController.setOtherUserNameAndId(userName, userId);
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
      bottomNavigationBar: MomentumBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /* @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Llista d\'usuaris')),
      body: Obx(() {
        if (xatController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: xatController.users.length,
          itemBuilder: (context, index) {
            final userPair = xatController.users[index];
            final userName = userPair[0];
            final userId = userPair[1];

            return ListTile(
              title: Text(userName),
              onTap: () async {
                try {
                  xatController.chatId.value = '';
                  xatController.chatMessages.clear();
                  await xatController.getChatId(currentUserId, userId);
                  final chatId = xatController.chatId.value;
                  if (!mounted) return;
                  if (xatController.chatId.value.isEmpty) {
                    Get.snackbar("Error", "Chat ID is empty");
                    return;
                  }
                  await xatController.setChatId(chatId);
                  await xatController.setOtherUserNameAndId(userName, userId);
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
            );
          },
        );
      }),
      bottomNavigationBar: MomentumBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
*/
}
