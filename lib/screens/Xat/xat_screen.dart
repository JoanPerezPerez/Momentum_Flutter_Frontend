import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class XatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;

  const XatScreen({
    Key? key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
  }) : super(key: key);

  @override
  State<XatScreen> createState() => _XatScreenState();
}

class _XatScreenState extends State<XatScreen> {
  final List<types.Message> _messages = [];
  late types.User _user;

  @override
  void initState() {
    super.initState();
    _user = types.User(id: widget.currentUserId);
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
