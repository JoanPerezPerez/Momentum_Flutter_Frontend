import 'package:get/get.dart';
import 'package:momentum/controllers/optimization_controller.dart';
import 'package:momentum/controllers/calendar_controller.dart';
class OptimizationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OptimizationController>(() => OptimizationController());
    if (!Get.isRegistered<CalendarController>()) {
      Get.put(CalendarController());
    }
  }
}
