import 'package:get/get.dart';
import 'package:momentum/routes/app_routes.dart';
import 'package:momentum/services/admin_service.dart';
import 'package:momentum/models/location_model.dart';

class AdminController extends GetxController {
  AdminService adminService = new AdminService();
  Rx<ILocation> location =
      ILocation(
        id: '',
        nombre: '',
        address: '',
        phone: '',
        rating: 0.0,
        ubicacion: GeoJSONPoint(type: 'Point', coordinates: [0.0, 0.0]),
        serviceType: <locationServiceType>[],
        schedule: <LocationSchedule>[],
        business: '',
        workers: <String>[],
      ).obs;

  Future<void> registerLocation() async {
    try {
      AdminService.registerLocation(location.value);
      Get.snackbar("Success", "Location enregistrada");
      Get.toNamed(AppRoutes.profile);
    } catch (e) {
      Get.snackbar("Error", "Posting the location failed: $e");
    }
  }
}
