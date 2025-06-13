import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';

class BusinessRegisterScreen extends StatefulWidget {
  @override
  State<BusinessRegisterScreen> createState() => _BusinessRegisterScreenState();
}

class _BusinessRegisterScreenState extends State<BusinessRegisterScreen> {
  final AuthController authController = Get.find();

  late String name = '';
  late String businessName = '';
  late String email = '';
  late String password = '';
  late String confirmPassword = '';
  late int age = 0;
  bool isLoading = false;

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

  Future<void> handleRegister() async {
    setState(() => isLoading = true);
    try {
      await authController.registerBusiness(
        name,
        businessName,
        age,
        email,
        password,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool passwordError = password.isNotEmpty && password.length < 6;
    final bool confirmPasswordError =
        confirmPassword.isNotEmpty && confirmPassword != password;

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
                        'Momentum Negocis',
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
                  onChanged: (value) => setState(() => name = value),
                  decoration: getInputDecoration("Nom responsable"),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) => setState(() => businessName = value),
                  decoration: getInputDecoration("Nom del negoci"),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged:
                      (value) => setState(() => age = int.tryParse(value) ?? 0),
                  keyboardType: TextInputType.number,
                  decoration: getInputDecoration("Edat"),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) => setState(() => email = value),
                  decoration: getInputDecoration("Correu electrònic"),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) => setState(() => password = value),
                  obscureText: true,
                  decoration: getInputDecoration(
                    "Contrasenya",
                    errorText:
                        passwordError
                            ? 'La contrasenya ha de tenir com a mínim 6 caràcters'
                            : null,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) => setState(() => confirmPassword = value),
                  obscureText: true,
                  decoration: getInputDecoration(
                    "Repeteix la contrasenya",
                    errorText:
                        confirmPasswordError
                            ? 'Les contrasenyes no coincideixen'
                            : null,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isLoading || passwordError || confirmPasswordError
                            ? null
                            : handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              "Registrar negoci",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
