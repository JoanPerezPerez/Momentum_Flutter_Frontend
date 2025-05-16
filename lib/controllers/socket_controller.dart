import 'package:get/get.dart';
import 'package:momentum/controllers/xat_controller.dart';
import 'package:momentum/services/socket_service.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class SocketController extends GetxController {
  final SocketService socketService = Get.find<SocketService>();
  late XatController xatController;

  @override
  void onInit() {
    super.onInit();

    socketService.listen('test', (data) {
      print('New message response to test: $data');
    });

    socketService.listen('new_message', (data) {
      print('New message: $data');
      final textMessage = types.TextMessage(
        author: types.User(id: data['sender']),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: data['message'],
      );
      xatController = Get.find<XatController>();
      xatController.addChatMessage(textMessage);
    });
  }

  void sendMessage(String messageName, dynamic messageText) {
    socketService.sendMessage(messageName, messageText);
  }
}
