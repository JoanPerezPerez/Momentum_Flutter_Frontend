// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/xat_controller.dart';
import 'package:momentum/screens/Xat/xat_screen.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final XatController xatController = Get.put(XatController());

  @override
  void initState() {
    super.initState();
    xatController.getUserWithWhomUserChatted("67fbd42f94d8d6c13b471127");
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
                  await xatController.getChatId(
                    "67fbd42f94d8d6c13b471127",
                    userId,
                  );
                  final chatId = xatController.chatId.value;
                  if (!mounted) return;
                  if (xatController.chatId.value.isEmpty) {
                    Get.snackbar("Error", "Chat ID is empty");
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => XatScreen(
                            chatId: chatId,
                            currentUserId: "67fbd42f94d8d6c13b471127",
                            otherUserId: userId,
                            otherUserName: userName,
                          ),
                    ),
                  );
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
