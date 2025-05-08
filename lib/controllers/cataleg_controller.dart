import 'package:get/get.dart';
import 'package:momentum/services/cataleg_service.dart';
import 'package:momentum/models/user_model.dart';
import 'package:momentum/models/location_model.dart';
import 'package:momentum/models/business_model.dart';

class CatalegController extends GetxController {
  var businesses = <BusinessWithLocations>[].obs;
  var isLoading = false.obs;
  var selectedServices = <locationServiceType>{}.obs;
  var listCities = <String>[].obs;
  var selectedCities = <String>{}.obs;
  var selectedOpenDay = RxnString();
  var selectedOpenTime = RxnString();
  final ratingMin = RxnDouble();

  void setRatingMin(double? value) {
    ratingMin.value = value;
  }

  void setSelectedOpenDayAndTime(String? day, String? time) {
    selectedOpenDay.value = day;
    selectedOpenTime.value = time;
  }
  void toggleService(locationServiceType service, bool isSelected) {
    if (isSelected) {
      selectedServices.add(service);
    } else {
      selectedServices.remove(service);
    }
  }

  void clearSelectedServices() {
    selectedServices.clear();
  }

  void toggleCity(String city, bool isSelected) {
    if (isSelected) {
      selectedCities.add(city);
    } else {
      selectedCities.remove(city);
    }
  }

  Future<void> getCitiesFilter()async{
    isLoading.value = true;
    try {
      final response = await CatalegService.getAllCities();
      if (response.isNotEmpty) {
        listCities.value = response;
      } else {
        Get.snackbar("Error", "Cities not correctly charged.");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAllBusiness() async {
    isLoading.value = true;
    try {
      final response = await CatalegService.getAllBusiness();
      if (response.isNotEmpty) {
        businesses.value = response;
      } else {
        Get.snackbar("Error", "No businesses available.");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> getFilteredBusiness(Map<String, dynamic> filters) async {
    isLoading.value = true;
    try {
      final response = await CatalegService.getFilteredBusiness(filters);
      if (response.isNotEmpty) {
        businesses.value = response;
      } else {
        businesses.clear();
        Get.snackbar("Sense resultats", "No s'han trobat negocis amb els filtres aplicats.");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
