import 'package:get/get.dart';
import 'package:momentum/controllers/socket_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SocketController>(() => SocketController());
  }
}
