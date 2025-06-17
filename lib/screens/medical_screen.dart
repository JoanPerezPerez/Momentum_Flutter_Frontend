import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:momentum/models/location_model.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/widgets/card/medical_card.dart';

class MedicalScreen extends StatefulWidget {
  const MedicalScreen({super.key});

  @override
  State<MedicalScreen> createState() => _MedicalScreenState();
}

class _MedicalScreenState extends State<MedicalScreen> {
  AuthController controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _loadMedicalLocations();
  }

  Future<void> _loadMedicalLocations() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("Ubicació desactivada", "Activa els serveis de localització.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("Permís denegat", "No es pot accedir a la ubicació sense permís.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          "Permís permanentment denegat",
          "Vés a la configuració del dispositiu per permetre l'accés a la ubicació.",
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      controller.userLat.value = position.latitude;
      controller.userLng.value = position.longitude;

      await controller.getCloseMedicalLocations();
    } catch (e) {
      Get.snackbar("Error d'ubicació", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Servei d'urgències a prop teu"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.closeMedicalLocations.isEmpty) {
          return const Center(child: Text("No s'han trobat ubicacions mèdiques."));
        }

        return ListView.builder(
          itemCount: controller.closeMedicalLocations.length,
          itemBuilder: (context, index) {
            final location = controller.closeMedicalLocations[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: MedicalCard(location: location),
            );
          },
        );
      }),
    );
  }
}
