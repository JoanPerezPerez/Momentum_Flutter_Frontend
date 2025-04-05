import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';


class SecondScreen extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pantalla de Registre")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => authController.name.value = value,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) => authController.age.value = int.tryParse(value) ?? 0,
              decoration: InputDecoration(
                labelText: "Age",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) => authController.email.value = value,
              decoration: InputDecoration(
                labelText: "Enter your email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) => authController.password.value = value,
              decoration: InputDecoration(
                labelText: "Enter your password",
                border: OutlineInputBorder(),
                errorText: authController.password.value.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) => authController.confirmPassword.value = value,
              decoration: InputDecoration(
                labelText: "Repeat your password",
                border: OutlineInputBorder(),
                errorText: authController.confirmPassword.value != authController.password.value
                    ? 'Passwords do not match'
                    : null,
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  onPressed: authController.isLoading.value ? null : authController.register,
                  child: authController.isLoading.value ? CircularProgressIndicator() : Text("Register"),
                )),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
