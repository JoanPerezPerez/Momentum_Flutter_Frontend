import 'package:get/get.dart';
import 'package:momentum/controllers/xat_controller.dart';
import 'package:momentum/services/socket_service.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class SocketController extends GetxController {
  late SocketService socketService;
  final XatController xatController = Get.find<XatController>();

  @override
  void onInit() {
    super.onInit();
    socketService = Get.find<SocketService>();

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
      xatController.addChatMessage(textMessage);
    });
  }

  void sendMessage(String messageName, dynamic messageText) {
    socketService.sendMessage(messageName, messageText);
  }
}
