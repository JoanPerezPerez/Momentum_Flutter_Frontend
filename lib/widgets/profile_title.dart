import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';

class ProfileTitle extends StatelessWidget {
  const ProfileTitle({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find<AuthController>();

    late final String text;
    if (authController.selectedRole.value == "worker" &&
        authController.currentWorker.value.role == "admin") {
      text = "Perfil d'admin";
    } else if (authController.selectedRole.value == "worker") {
      text = "Perfil de treballador";
    } else if (authController.selectedRole.value == "user") {
      text = "Perfil d'usuari";
    } else {
      text = "UNKNOWN";
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.07;
    fontSize = fontSize.clamp(20, 32);
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
      textAlign: TextAlign.center,
    );
  }
}
