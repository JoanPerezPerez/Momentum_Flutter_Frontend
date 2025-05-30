import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';

class PasswordChangeCard extends StatefulWidget {
  @override
  _PasswordChangeCardState createState() => _PasswordChangeCardState();
}

class _PasswordChangeCardState extends State<PasswordChangeCard> {
  final AuthController authController = Get.find();

  String currentPassword = "";
  String newPassword = "";
  String repeatPassword = "";

  String? get newPasswordError {
    if (newPassword.isNotEmpty && newPassword.length < 6) {
      return 'La contrasenya ha de tenir com a mínim 6 caràcters';
    }
    return null;
  }

  String? get repeatPasswordError {
    if (repeatPassword.isNotEmpty && repeatPassword != newPassword) {
      return 'Les contrasenyes no coincideixen';
    }
    return null;
  }

  InputDecoration getInputDecoration(String label, {String? errorText}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.blue.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue, width: 2.0),
        borderRadius: BorderRadius.circular(12),
      ),
      floatingLabelStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
      errorText: errorText,
    );
  }

  bool get isFormValid {
    return newPasswordError == null &&
        repeatPasswordError == null &&
        currentPassword.isNotEmpty &&
        newPassword.isNotEmpty &&
        repeatPassword.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => setState(() => currentPassword = value),
              obscureText: true,
              decoration: getInputDecoration('Contrasenya actual'),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) => setState(() => newPassword = value),
              obscureText: true,
              decoration: getInputDecoration(
                'Nova contrasenya',
                errorText: newPasswordError,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) => setState(() => repeatPassword = value),
              obscureText: true,
              decoration: getInputDecoration(
                'Repeteix la nova contrasenya',
                errorText: repeatPasswordError,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed:
                      isFormValid
                          ? () {
                            authController.changePassword(
                              currentPassword,
                              newPassword,
                              repeatPassword,
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    authController.togglePasswordCard(); // Amaga la card
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blueAccent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sortir',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
