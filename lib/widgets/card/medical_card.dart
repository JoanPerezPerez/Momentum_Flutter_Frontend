import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/map_controller.dart';
import 'package:momentum/models/location_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:momentum/controllers/map_controller.dart'
    as MomentumMapController;

class MedicalCard extends StatelessWidget {
  final ILocation location;
  const MedicalCard({super.key, required this.location});

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => _showLocationDetail(context, location),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(right: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      location.nombre,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue, size: 20),
                    onPressed: () {
                      if (!Get.isRegistered<MomentumMapController.MapController>()) {
                        Get.put(MomentumMapController.MapController());
                      }
                      final lat = location.ubicacion.coordinates[1];
                      final lon = location.ubicacion.coordinates[0];
                      Get.find<MomentumMapController.MapController>().markers.assignAll([
                        Marker(
                          point: LatLng(lat, lon),
                          width: 80,
                          height: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ],
                          ),
                        ),
                      ]);
                      Get.toNamed('/map', arguments: {
                        'lat': lat,
                        'lon': lon,
                        'location': location,
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(location.address, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(child: Text(location.phone, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(location.rating.toStringAsFixed(1)),
                  const SizedBox(width: 15),
                  if (location.accessible) ...[
                    const Icon(Icons.accessible, size: 16, color: Colors.green),
                    const SizedBox(width: 6),
                    const Text('Accessible', overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: location.serviceType
                    .take(3)
                    .map((type) => Chip(
                          label: Text(type.description, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.blue[50],
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationDetail(BuildContext context, ILocation location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    location.nombre,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(location.address),
                  Text(location.phone),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${location.rating}/5'),
                      const SizedBox(width: 12),
                      if (location.accessible) ...[
                        const Icon(Icons.accessible, color: Colors.green),
                        const SizedBox(width: 6),
                        const Text('Accessible'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Serveis disponibles:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: location.serviceType.map((type) {
                      return Chip(
                        label: Text(type.description),
                        backgroundColor: Colors.blue[100],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (location.schedule.isNotEmpty) ...[
                    const Text(
                      'Horari:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: location.schedule.map((s) {
                        return Text('${s.day}: ${s.openingTime} - ${s.closingTime}');
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

