import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/widgets/profile_actions.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find<AuthController>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      late final String name;
      late final int age;
      late final String mail;
      late final String photo;
      final what = authController.selectedRole.value;

      if (what == "worker") {
        final worker = authController.currentWorker.value;
        photo = worker.name.isNotEmpty ? worker.name[0].toUpperCase() : '?';
        name = worker.name.isNotEmpty ? worker.name.toUpperCase() : '?';
        age = worker.age;
        mail = worker.mail;
      } else if (what == "user") {
        final user = authController.currentUser.value;
        photo = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
        name = user.name.isNotEmpty ? user.name.toUpperCase() : '?';
        age = user.age;
        mail = user.mail;
      } else {
        photo = '?';
        name = 'UNKNOWN';
        age = 0;
        mail = '';
      }
      
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: screenHeight * 0.75),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.13,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      photo,
                      style: TextStyle(
                        fontSize: screenWidth * 0.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  Text(
                    '$age anys',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  Text(
                    mail,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  const ProfileActions(),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}