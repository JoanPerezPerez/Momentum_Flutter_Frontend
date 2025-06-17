import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:momentum/controllers/map_controller.dart'
    as MomentumMapController;
import 'package:momentum/controllers/xat_controller.dart';
import 'package:momentum/models/location_model.dart';
import 'package:momentum/routes/app_routes.dart';
import 'package:momentum/widgets/xat/start_chat.dart';

class PopupMarkerLayerWidgetReactive extends StatelessWidget {
  final PopupController popupController;
  final MomentumMapController.MapController mapaController;

  PopupMarkerLayerWidgetReactive({
    super.key,
    required this.popupController,
    required this.mapaController,
  });

  @override
  Widget build(BuildContext context) {
    final XatController xatController = Get.find();
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
                      accessible: false,
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
                              onPressed: () {
                                Get.toNamed(AppRoutes.reqAppointments, arguments: {
                                  'locationId': selectedLocation.id, 
                                  'locationName': selectedLocation.nombre,                            
                                  /*'serviceType': selectedLocation.serviceType.isNotEmpty 
                                    ? selectedLocation.serviceType[0].toString() 
                                    : "general",// selectedLocation.serviceType[0],*/
                                });
                              },
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.call, size: 18),
                              label: const Text('Call'),
                              onPressed: () {},
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.message, size: 18),
                              label: const Text('Send message'),
                              onPressed: () {
                                xatController.findPossibleXatRecipients(
                                  selectedLocation.id,
                                );
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        contentPadding: const EdgeInsets.all(8),
                                        content: SizedBox(
                                          width: 400,
                                          child: StartChatCard(
                                            locationName:
                                                selectedLocation.nombre,
                                            locationId: selectedLocation.id,
                                            businessId:
                                                selectedLocation.business,
                                          ),
                                        ),
                                      ),
                                );
                              },
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
