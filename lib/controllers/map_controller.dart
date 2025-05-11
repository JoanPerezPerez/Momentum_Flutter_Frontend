import 'package:get/get.dart';
import 'package:momentum/services/mapa_service.dart';
import 'package:momentum/models/location_model.dart';

class MapController extends GetxController {
  var locations = <ILocation>[].obs;
  var isLoading = false.obs;

  Future<void> getAllLocationsByServiceType(String value) async {
    isLoading.value = true;
    try {
      final response = await MapService.getAllLocationsByServiceType(value);
      if (response.isNotEmpty) {
        locations.value = response;
      } else {
        Get.snackbar("Error", "No locations found for the given service type.");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
