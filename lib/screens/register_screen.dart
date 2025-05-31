import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  final AuthController authController = Get.find();

  InputDecoration getInputDecoration(String label, {String? errorText}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.blue.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2.0),
        borderRadius: BorderRadius.circular(12),
      ),
      floatingLabelStyle: TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
      errorText: errorText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', height: 100),
                      const SizedBox(height: 2),
                      const Text(
                        'Momentum',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  onChanged: (value) => authController.name.value = value,
                  decoration: getInputDecoration("Nom"),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged:
                      (value) =>
                          authController.age.value = int.tryParse(value) ?? 0,
                  keyboardType: TextInputType.number,
                  decoration: getInputDecoration("Edat"),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) => authController.email.value = value,
                  decoration: getInputDecoration("Correu electrònic"),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) => authController.password.value = value,
                  obscureText: true,
                  decoration: getInputDecoration(
                    "Contrasenya",
                    errorText:
                        authController.password.value.isNotEmpty &&
                                authController.password.value.length < 6
                            ? 'La contrasenya ha de tenir com a mínim 6 caràcters'
                            : null,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged:
                      (value) => authController.confirmPassword.value = value,
                  obscureText: true,
                  decoration: getInputDecoration(
                    "Repeteix la contrasenya",
                    errorText:
                        authController.confirmPassword.value.isNotEmpty &&
                                authController.confirmPassword.value !=
                                    authController.password.value
                            ? 'Les contrasenyes no coincideixen'
                            : null,
                  ),
                ),
                const SizedBox(height: 30),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          authController.isLoading.value
                              ? null
                              : authController.register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          authController.isLoading.value
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                "Registrar-se",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Torna enrere",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
