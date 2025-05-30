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
}
