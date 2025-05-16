import 'package:get/get.dart';
import 'package:momentum/services/mapa_service.dart';
import 'package:momentum/models/location_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:momentum/controllers/map_controller.dart'
    as MomentumMapController;
import 'dart:async';

class MapController extends GetxController {
  var locations = <ILocation>[].obs;
  var markers = <Marker>[].obs;

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

  List<Marker> buildMarkersFromGeoJSON(
    List<ILocation> points,
    PopupController _popupController,
  ) {
    return points.map((point) {
      return Marker(
        point: LatLng(
          point.ubicacion.coordinates[1],
          point.ubicacion.coordinates[0],
        ), // [lat, lon]
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap:
              () => _popupController.showPopupsOnlyFor([
                Marker(
                  point: LatLng(
                    point.ubicacion.coordinates[1],
                    point.ubicacion.coordinates[0],
                  ),
                  width: 80,
                  height: 80,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_pin, color: Colors.red, size: 40),
                      Text(
                        point.nombre,
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_pin, color: Colors.red, size: 40),
              Text(
                point.nombre,
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void getLocations(
    String locationType,
    PopupController popupController,
  ) async {
    await getAllLocationsByServiceType(locationType);
    List<GeoJSONPoint> resultingPoints = [];
    for (var location in locations) {
      resultingPoints.add(location.ubicacion);
    }
    final List<Marker> locationMarkers = buildMarkersFromGeoJSON(
      locations,
      popupController,
    );
    markers.assignAll(locationMarkers);
  }
}
