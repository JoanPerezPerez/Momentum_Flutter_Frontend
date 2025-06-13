import 'package:get/get.dart';
import 'package:momentum/controllers/amistats_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FriendController>(() => FriendController());
    
  }
}
