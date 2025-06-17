import 'package:get/get.dart';
import 'package:momentum/controllers/map_controller.dart' as MomentumMapController;

class MapBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MomentumMapController.MapController>()) {
      Get.put<MomentumMapController.MapController>(
        MomentumMapController.MapController(),
        permanent: false, // o true si vols que persisteixi sempre
      );
    }
  }
}