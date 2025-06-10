import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:momentum/controllers/xat_controller.dart';
import 'package:get/get.dart';

class XatScreen extends StatefulWidget {
  const XatScreen({Key? key}) : super(key: key);

  @override
  State<XatScreen> createState() => _XatScreenState();
}

class _XatScreenState extends State<XatScreen> {
  final XatController xatController = Get.find<XatController>();

  @override
  void initState() {
    super.initState();
    xatController.setUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      xatController.fetchMessages();
    });
    //xatController.login();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Xat amb ${xatController.otherUser.value.name}')),
        leading: Obx(
          () =>
              xatController.myChatType.value == "location" ||
                      xatController.myChatType.value == "business"
                  ? TextButton(
                    onPressed: () => xatController.editXatToAssignToMe(),
                    child: Text(
                      'Assignar',
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                  : SizedBox.shrink(), // Widget buit quan no es mostra
        ),
      ),
      body: Obx(
        () => Chat(
          messages: xatController.messages.toList(),
          onSendPressed: xatController.handleSendPressed,
          user: xatController.user,
        ),
      ),
    );
  }
}
