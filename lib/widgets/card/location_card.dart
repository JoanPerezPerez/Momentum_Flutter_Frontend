import 'package:flutter/material.dart';
import 'package:momentum/controllers/cataleg_controller.dart';
import 'package:momentum/models/location_model.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:get/get.dart';

class LocationCard extends StatelessWidget {
  final ILocation location;

  const LocationCard({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

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
                  Obx(() => IconButton(
                        icon: Icon(
                          authController.currentUser.value.favoriteLocations.contains(location.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => _toggleFavorite(location.id),
                      )),
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
  void _toggleFavorite(String locationId) async {
    final authController = Get.find<AuthController>();
    final catalegController = Get.find<CatalegController>();

    final favorites = authController.currentUser.value.favoriteLocations;

    final userId = authController.currentUser.value.id;
    if (userId == null) {
      Get.snackbar("Error", "S'ha produït un error");
      return;
    }

    final success = await catalegController.toggleFavoriteLocation(userId, locationId);

    if (success) {
      if (favorites.contains(locationId)) {
        favorites.remove(locationId);
      } else {
        favorites.add(locationId);
      }
      authController.currentUser.refresh(); 
    } else {
      Get.snackbar("Error", "No s'ha pogut actualitzar el favorit.");
    }
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
