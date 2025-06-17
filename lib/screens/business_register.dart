import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';

class BusinessRegisterScreen extends StatefulWidget {
  @override
  State<BusinessRegisterScreen> createState() => _BusinessRegisterScreenState();
}

class _BusinessRegisterScreenState extends State<BusinessRegisterScreen> {
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

  Widget passwordRequirement({required bool fulfilled, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle,
          color: fulfilled ? Colors.blue : Colors.grey.shade400,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded( 
          child: Text(
            text,
            style: TextStyle(
              color: fulfilled ? Colors.blue : Colors.grey.shade600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1, 
          ),
        ),
      ],
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
                  onChanged: (value) => authController.name.value = value,
                  decoration: getInputDecoration("Nom responsable"),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) => authController.businessName.value = value,
                  decoration: getInputDecoration("Nom del negoci"),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged:
                      (value) => authController.age.value = int.tryParse(value) ?? 0,
                  keyboardType: TextInputType.number,
                  decoration: getInputDecoration("Edat"),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) => authController.email.value = value,
                  decoration: getInputDecoration("Correu electrònic"),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  final password = authController.password.value;
                  final confirm = authController.confirmPassword.value;
                  final match = confirm == password && confirm.isNotEmpty;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        onChanged: authController.updatePassword,
                        obscureText: true,
                        decoration: getInputDecoration(
                          "Contrasenya",
                          errorText: password.isNotEmpty &&
                                  authController.validatePassword(password) != null
                              ? ''
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        onChanged: (value) => authController.confirmPassword.value = value,
                        obscureText: true,
                        decoration: getInputDecoration(
                          "Repeteix la contrasenya",
                          errorText: confirm.isNotEmpty && !match ? '' : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      passwordRequirement(
                        fulfilled: authController.hasMinLength.value,
                        text: "Almenys 8 caràcters",
                      ),
                      passwordRequirement(
                        fulfilled: authController.hasTwoUppercase.value,
                        text: "Almenys 2 majúscules",
                      ),
                      passwordRequirement(
                        fulfilled: authController.hasSpecialChar.value,
                        text: "Almenys 1 caràcter especial",
                      ),
                      if (confirm.isNotEmpty)
                        passwordRequirement(
                          fulfilled: match,
                          text: "Les contrasenyes coincideixen",
                        ),
                    ],
                  );
                }),
                const SizedBox(height: 30),
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authController.isLoading.value ||
                            authController.validatePassword(authController.password.value) != null ||
                            authController.password.value != authController.confirmPassword.value
                        ? null
                        : authController.registerBusiness,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: authController.isLoading.value
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
                )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => {authController.registerClean(),Get.back()},
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
