import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:momentum/controllers/xat_controller.dart';
import 'package:get/get.dart';
import 'package:momentum/models/message_model.dart';
import 'package:uuid/uuid.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/controllers/socket_controller.dart';

class XatScreen extends StatefulWidget {
  const XatScreen({Key? key}) : super(key: key);

  @override
  State<XatScreen> createState() => _XatScreenState();
}

class _XatScreenState extends State<XatScreen> {
  late XatController xatController = Get.find<XatController>();
  late AuthController authController = Get.find<AuthController>();
  late SocketController socketController = Get.find<SocketController>();
  late types.User _user;

  @override
  void initState() {
    super.initState();
    _user = types.User(id: authController.currentUser.value.name);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMessages();
    });
    socketController.sendMessage(
      'user_login',
      authController.currentUser.value.name,
    );
  }

  void _fetchMessages() async {
    if (!mounted) return;
    final cleanId = xatController.chatId.replaceAll('"', '');
    await xatController.getChatMessages(cleanId);
    final messages = convertToTextMessages(
      xatController.chatMessages,
      authController.currentUser.value.id as String,
    );
    xatController.setChatMessages(messages);
  }

  List<types.TextMessage> convertToTextMessages(
    List<dynamic> messagesFromApi,
    String currentUserId,
  ) {
    final uuid = const Uuid();

    return messagesFromApi.map((msg) {
      if (msg is ChatMessage) {
        return types.TextMessage(
          id: uuid.v4(),
          author: types.User(id: msg.from ?? 'unknown'),
          createdAt: msg.timestamp?.millisecondsSinceEpoch ?? 0,
          text: msg.text ?? '',
        );
      } else if (msg is Map<String, dynamic>) {
        final timestamp = DateTime.tryParse(msg['timestamp']?.toString() ?? '');
        return types.TextMessage(
          id: msg['from']?.toString() ?? uuid.v4(),
          author: types.User(id: msg['from'] ?? 'unknown'),
          createdAt: timestamp?.millisecondsSinceEpoch ?? 0,
          text: msg['text'] ?? '',
        );
      } else {
        throw Exception("Format de missatge desconegut: ${msg.runtimeType}");
      }
    }).toList();
  }

  // Funció per gestionar l'enviament de missatges
  void _handleSendPressed(types.PartialText message) async {
    final cleanId = xatController.chatId.replaceAll('"', '');
    await xatController.sendMessage(
      cleanId,
      authController.currentUser.value.name,
      message.text,
    );
    if (xatController.correctlySent.value == false) {
      Get.snackbar("Error", "Failed to send message");
      return;
    }
    socketController.sendMessage('new_message', {
      'chatId': cleanId,
      'sender': authController.currentUser.value.name,
      'message': message.text,
    });
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.text,
    );
    xatController.messages.insert(0, textMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Xat amb ${xatController.otherUser.value.name}')),
      ),
      body: Obx(
        () => Chat(
          messages: xatController.messages.toList(),
          onSendPressed: _handleSendPressed,
          user: _user,
        ),
      ),
    );
  }
}
