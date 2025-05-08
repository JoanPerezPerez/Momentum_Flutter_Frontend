import 'package:get/get.dart';
import 'package:momentum/controllers/cataleg_controller.dart';

class CatalegBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CatalegController>(() => CatalegController());
  }
}
