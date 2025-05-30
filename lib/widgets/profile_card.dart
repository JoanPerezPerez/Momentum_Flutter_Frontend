import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/widgets/profile_actions.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});
  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find<AuthController>();
    return Obx(() {
      late final name;
      late final age;
      late final mail;
      late final photo;
      final what = authController.selectedRole;
      if (what == "worker") {
        final worker = authController.currentWorker;
        photo =
            worker.value.name.isNotEmpty
                ? worker.value.name[0].toUpperCase()
                : '?';
        name =
            worker.value.name.isNotEmpty
                ? worker.value.name.toUpperCase()
                : '?';
        age = worker.value.age;
        mail = worker.value.mail;
      }
      if (what == "user") {
        final user = authController.currentUser;
        photo =
            user.value.name.isNotEmpty ? user.value.name[0].toUpperCase() : '?';
        name = user.value.name.isNotEmpty ? user.value.name.toUpperCase() : '?';
        age = user.value.age;
        mail = user.value.mail;
      }
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Text(
                  photo,
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${age} anys',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                mail,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const ProfileActions(),
            ],
          ),
        ),
      );
    });
  }
}
