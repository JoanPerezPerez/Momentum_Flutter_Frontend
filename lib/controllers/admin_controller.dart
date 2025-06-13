import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/models/worker_model.dart' as my_models;
import 'package:momentum/routes/app_routes.dart';
import 'package:momentum/services/admin_service.dart';
import 'package:momentum/models/location_model.dart';

class AdminController extends GetxController {
  AdminService adminService = AdminService();
  AuthController authController = Get.find();
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
  Rx<my_models.Worker> worker =
      my_models.Worker(
        id: '',
        name: '',
        mail: '',
        age: 0,
        role: '',
        location: [],
        businessAdministrated: '',
      ).obs;

  var locations = <ILocation>[].obs;

  RxBool isUpdate = true.obs;

  Future<void> registerLocation() async {
    try {
      await AdminService.registerLocation(location.value);
      Get.snackbar("Success", "Location enregistrada");
      Get.toNamed(AppRoutes.profile);
    } catch (e) {
      Get.snackbar("Error", "Posting the location failed: $e");
    }
  }

  /*   Future<void> registerWorker({required String locationName}) async {
    try {
      await AdminService.registerWorker(worker.value, locationName);
      Get.snackbar("Success", "Worker enregistrada");
      Get.toNamed(AppRoutes.profile);
    } catch (e) {
      Get.snackbar("Error", "Posting the worker failed: $e");
    }
  } */

  Future<void> registerWorker() async {
    try {
      await AdminService.registerWorker(worker.value);
      Get.snackbar("Success", "Worker enregistrade");
      Get.toNamed(AppRoutes.profile);
    } catch (e) {
      Get.snackbar("Error", "Posting the worker failed: $e");
    }
  }

  Future<void> updateWorker() async {
    try {
      await AdminService.updateWorker(worker.value, worker.value.id as String);
      Get.snackbar("Success", "Worker updated");
      isUpdate.value = false;
      Get.toNamed(AppRoutes.profile);
    } catch (e) {
      Get.snackbar("Error", "Updating the worker failed: $e");
    }
  }

  Future<void> getAllLocationsOfBusiness() async {
    try {
      locations.value = await AdminService.getAllLocationsOfBusiness(
        authController.currentWorker.value.businessAdministrated as String,
      );
    } catch (e) {
      Get.snackbar("Error", "Error loading the locations of the business");
    }
  }

  Future<void> tryUpdateWorker(String workerName) async {
    try {
      worker.value = await AdminService.getWorkerFromName(workerName);
      isUpdate.value = true;
      Get.toNamed(AppRoutes.workerRegister);
    } catch (e) {
      Get.snackbar("Error", "Error loading the worker, try a diferent name");
    }
  }
}
