import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/widgets/profile_actions.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = Get.find<AuthController>().currentUser;
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
                  user.value.name.isNotEmpty
                      ? user.value.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.value.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${user.value.age} anys',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                user.value.mail,
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
