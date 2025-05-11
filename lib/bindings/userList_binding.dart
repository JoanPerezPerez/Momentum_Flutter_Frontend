import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/controllers/xat_controller.dart';

class UserlistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<XatController>(() => XatController());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
