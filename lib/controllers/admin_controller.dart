//import 'dart:ffi';

import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/models/worker_model.dart' as my_models;
import 'package:momentum/routes/app_routes.dart';
import 'package:momentum/services/admin_service.dart';
import 'package:momentum/models/location_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
        accessible: false,
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

  Future<bool> registerLocationWithGeocoding({
    required String nombre,
    required String phone,
    required String address,
    required List<locationServiceType> serviceType,
    required List<LocationSchedule> schedule,
    required bool accessible,
  }) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'MomentumAppFlutter/1.0 (momentumea2025@gmail.com)'
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.tryParse(data[0]['lat']);
          final lon = double.tryParse(data[0]['lon']);

          if (lat != null && lon != null) {
            location.value = ILocation(
              id: '',
              nombre: nombre,
              address: address,
              phone: phone,
              rating: 0.0,
              ubicacion: GeoJSONPoint(
                type: 'Point',
                coordinates: [lon, lat],
              ),
              serviceType: serviceType,
              schedule: schedule,
              business: '',
              workers: [],
              accessible: accessible,
            );

            await registerLocation();
            return true;
          }
        }
      }

      Get.snackbar('Error', 'No s\'han trobat coordenades vàlides.');
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Error en obtenir coordenades: $e');
      return false;
    }
  }


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
