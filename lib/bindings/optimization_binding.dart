import 'package:get/get.dart';
import 'package:momentum/controllers/optimization_controller.dart';

class OptimizationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OptimizationController>(() => OptimizationController());
  }
}
