// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/xat_controller.dart';
import 'package:momentum/routes/app_routes.dart';
import 'package:momentum/screens/Xat/xat_screen.dart';
import 'package:momentum/controllers/auth_controller.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late XatController xatController;
  late AuthController authController;

  @override
  void initState() {
    super.initState();
    xatController = Get.find<XatController>();
    authController = Get.find<AuthController>();
    xatController.getUserWithWhomUserChatted(
      authController.currentUser.value.id as String,
    );
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
                  print(userId);
                  print(
                    "current user id: ${authController.currentUser.value.id}",
                  );
                  await xatController.getChatId(
                    authController.currentUser.value.id as String,
                    userId,
                  );
                  final chatId = xatController.chatId.value;
                  if (!mounted) return;
                  if (xatController.chatId.value.isEmpty) {
                    Get.snackbar("Error", "Chat ID is empty");
                    return;
                  }
                  await xatController.setChatId(chatId);
                  await xatController.setOtherUserNameAndId(userName, userId);
                  Get.toNamed(AppRoutes.xat);
                  /*                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => XatScreen()),
                  ); */
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
    );
  }
}
