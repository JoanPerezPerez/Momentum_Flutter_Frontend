import 'package:get/get.dart';
import 'package:momentum/controllers/appointment_map_controller.dart';

class AppointmentMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppointmentMapController>(() => AppointmentMapController());
  }
}