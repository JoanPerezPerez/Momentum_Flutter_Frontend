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
  var userLat = RxnDouble();
  var userLng = RxnDouble();
  var maxDistanceKm = RxnDouble();

  void setUserLocation(double? lat, double? lng) {
    userLat.value = lat;
    userLng.value = lng;
  }

  void setMaxDistanceKm(double? km) {
    maxDistanceKm.value = km;
  }

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

  void clearFilter() {
    selectedServices.clear();
    selectedCities.clear();
    selectedOpenDay.value = null;
    selectedOpenTime.value = null;
    ratingMin.value = null;
    maxDistanceKm.value = null;
    userLat.value = null;
    userLng.value = null;
    businesses.clear();
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

  Future<void> searchBusinessLocationByName(String name) async {
    isLoading.value = true;
    try {
      final List<BusinessWithLocations> response = await CatalegService.searchBusinessByName(name);

      if (response.isNotEmpty) {
        businesses.value = response; 
      } else {
        businesses.clear();
        Get.snackbar("Sense resultats", "No s'han trobat negocis ni botigues amb aquest nom.");
      }
    } catch (e) {
      Get.snackbar("Error", "S'ha produït un error: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getFavoriteBusinesses(String? userId) async {
    isLoading.value = true;
    try {
      if (userId == null) {
        Get.snackbar("Error", "S'ha produït un error");
        return;
      }

      final List<BusinessWithLocations> response =
          await CatalegService.getFavoriteBusinesses(userId);

      if (response.isNotEmpty) {
        businesses.value = response;
      } else {
        businesses.clear();
        Get.snackbar("Sense resultats", "No hi ha negocis marcats com a favorits.");
      }
    } catch (e) {
      Get.snackbar("Error", "S'ha produït un error: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> getFilteredFavoriteBusinesses(String userId, Map<String, dynamic> filters) async {
    isLoading.value = true;
    try {
      final response = await CatalegService.getFilteredFavoriteBusinesses(userId, filters);
      if (response.isNotEmpty) {
        businesses.value = response;
      } else {
        businesses.clear();
        Get.snackbar("Sense resultats", "No hi ha negocis favorits amb aquests filtres.");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  Future<bool> toggleFavoriteLocation(String userId, String locationId) async {
    try {
      final success = await CatalegService.toggleFavoriteLocation(userId, locationId);

      if (success) {
        Get.snackbar("Actualitzat", "S'ha actualitzat el favorits correctament.");
        return success;
      } else {
        Get.snackbar("Error", "No s'ha pogut actualitzar el favorit.");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "S'ha produït un error: ${e.toString()}");
      return false;
    }
  }

  void removeLocationFromBusiness(String businessId, String locationIdToRemove) {
    final index = businesses.indexWhere((b) => b.id == businessId);
    if (index == -1) return; // No trobat

    final currentBusiness = businesses[index];

    final updatedLocations = currentBusiness.locations
        .where((location) => location.id != locationIdToRemove)
        .toList();

    if (updatedLocations.isEmpty) {
      // Si ja no queda cap location, elimina tot el business
      businesses.removeAt(index);
    } else {
      // Si encara en queden, actualitza el business
      final updatedBusiness = BusinessWithLocations(
        id: currentBusiness.id,
        name: currentBusiness.name,
        locations: updatedLocations,
        isDeleted: currentBusiness.isDeleted,
      );

      businesses[index] = updatedBusiness;
    }
  }


}
