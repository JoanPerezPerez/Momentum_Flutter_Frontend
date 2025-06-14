import 'package:get/get.dart';
import 'package:momentum/controllers/recordatoris_controller.dart';

class RecordatorisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecordatorisController>(() => RecordatorisController());
  }
}
