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
    print("khshbgaw.ugbalvaeubgvwbvr u.bvrv");
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => XatScreen(
                          currentUserId: "999",
                          otherUserId: userId,
                          otherUserName: userName,
                        ),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}
