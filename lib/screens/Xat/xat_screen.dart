import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:momentum/controllers/xat_controller.dart';
import 'package:get/get.dart';
import 'package:momentum/models/message_model.dart';
import 'package:uuid/uuid.dart';
import 'package:momentum/services/xat_service.dart';

class XatScreen extends StatefulWidget {
  final String currentUserName;
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String chatId;

  const XatScreen({
    Key? key,
    required this.currentUserName,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.chatId,
  }) : super(key: key);

  @override
  State<XatScreen> createState() => _XatScreenState();
}

class _XatScreenState extends State<XatScreen> {
  final XatController xatController = Get.put(XatController());
  final List<types.Message> _messages = [];
  late types.User _user;

  @override
  void initState() {
    super.initState();
    _user = types.User(id: widget.currentUserName);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMessages();
    });
  }

  void _fetchMessages() async {
    if (!mounted) return;
    final cleanId = widget.chatId.replaceAll('"', '');
    await xatController.getChatMessages(cleanId);
    final messages = convertToTextMessages(
      xatController.chatMessages,
      widget.currentUserId,
    );
    if (!mounted) return;

    setState(() {
      _messages.clear();
      _messages.addAll(messages);
    });
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
    final cleanId = widget.chatId.replaceAll('"', '');
    await xatController.sendMessage(
      cleanId,
      widget.currentUserName,
      message.text,
    );
    if (xatController.correctlySent.value == false) {
      Get.snackbar("Error", "Failed to send message");
      return;
    }
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage); // Afegim el nou missatge
    });

    // Mostrar el missatge popup com a simulació
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Xat amb ${widget.otherUserName}')),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
      ),
    );
  }
}
