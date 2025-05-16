import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:momentum/controllers/map_controller.dart'
    as MomentumMapController;
import 'package:momentum/models/location_model.dart';

class PopupMarkerLayerWidgetReactive extends StatelessWidget {
  final PopupController popupController;
  final MomentumMapController.MapController mapaController;

  const PopupMarkerLayerWidgetReactive({
    super.key,
    required this.popupController,
    required this.mapaController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final markers = mapaController.markers;
      final locations = mapaController.locations;

      return PopupMarkerLayerWidget(
        options: PopupMarkerLayerOptions(
          popupController: popupController,
          markers: markers.toList(),
          markerTapBehavior: MarkerTapBehavior.togglePopup(),
          popupDisplayOptions: PopupDisplayOptions(
            builder: (BuildContext context, Marker marker) {
              final LatLng position = marker.point;
              final ILocation selectedLocation = locations.firstWhere(
                (location) =>
                    location.ubicacion.coordinates[1] == position.latitude &&
                    location.ubicacion.coordinates[0] == position.longitude,
                orElse:
                    () => ILocation(
                      id: 'Unknown',
                      nombre: 'Unknown',
                      address: 'Unknown',
                      phone: 'Unknown',
                      rating: 0.0,
                      serviceType: [],
                      schedule: [],
                      business: 'Unknown',
                      workers: [],
                      isDeleted: false,
                      ubicacion: GeoJSONPoint(
                        type: 'Point',
                        coordinates: [0.0, 0.0],
                      ),
                    ),
              );

              if (selectedLocation.nombre == 'Unknown') {
                return const SizedBox.shrink();
              }

              return SizedBox(
                width: 300,
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedLocation.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${selectedLocation.rating.toStringAsFixed(1)}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          selectedLocation.address,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text('Tel: ${selectedLocation.phone}'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [
                            ActionChip(
                              avatar: const Icon(
                                Icons.calendar_month,
                                size: 18,
                              ),
                              label: const Text('Request appointment'),
                              onPressed: () {},
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.call, size: 18),
                              label: const Text('Call'),
                              onPressed: () {},
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.message, size: 18),
                              label: const Text('Send message'),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
