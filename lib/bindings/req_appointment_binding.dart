import 'package:get/get.dart';
import 'package:momentum/controllers/req_appointmentscreen_controller.dart';

class CatalegBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReqAppointmentscreenController>(() => ReqAppointmentscreenController());
  }
}
