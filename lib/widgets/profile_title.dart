import 'package:flutter/material.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:get/get.dart';

class ProfileTitle extends StatelessWidget {
  const ProfileTitle({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find<AuthController>();
    late final text;
    if (authController.selectedRole.value == "worker")
      text = "Perfil de treballador";
    else if (authController.selectedRole.value == "user")
      text = "Perfil d\'usuari";
    else
      text = "UNKNOWN";
    return Text(
      text,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }
}
