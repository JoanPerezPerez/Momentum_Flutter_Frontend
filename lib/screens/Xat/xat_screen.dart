import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:momentum/controllers/xat_controller.dart';
import 'package:get/get.dart';

class XatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String chatId;

  const XatScreen({
    Key? key,
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
    print("1");
    super.initState();
    _user = types.User(id: widget.currentUserId);
    _fetchMessages();
  }

  void _fetchMessages() async {
    print("uououo");
    if (!mounted) return;
    print("chat id at the xat screen: ${widget.chatId}");
    await xatController.getChatMessages(widget.chatId);
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
    return messagesFromApi.map((msg) {
      final isCurrentUser = msg['from'] == currentUserId;

      return types.TextMessage(
        id: UniqueKey().toString(), // Pots usar UUID si vols
        author: types.User(id: msg['from']),
        createdAt: DateTime.parse(msg['timestamp']).millisecondsSinceEpoch,
        text: msg['text'],
      );
    }).toList();
  }

  // Funció per gestionar l'enviament de missatges
  void _handleSendPressed(types.PartialText message) {
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
    _showPopup(message.text);
  }

  // Funció per mostrar el popup simulant l'enviament del missatge
  void _showPopup(String messageText) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Missatge enviat!'),
          content: Text('El missatge següent serà enviat: "$messageText"'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tancar'),
            ),
          ],
        );
      },
    );
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
