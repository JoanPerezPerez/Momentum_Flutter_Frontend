import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/admin_controller.dart';
import 'package:momentum/models/worker_model.dart' as my_models show Worker;
import 'package:momentum/routes/app_routes.dart';

class WorkerRegister extends StatefulWidget {
  @override
  _SimpleWorkerRegisterState createState() => _SimpleWorkerRegisterState();
}

class _SimpleWorkerRegisterState extends State<WorkerRegister> {
  final AdminController adminController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String role = 'worker';

  InputDecoration getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.blue.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void saveWorker() {
    adminController.worker.value = my_models.Worker(
      name: nameController.text,
      mail: emailController.text,
      age: int.tryParse(ageController.text) ?? 0,
      role: role,
      location: [],
      password: passwordController.text,
    );
    adminController.registerWorker(locationName: locationController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registre Simple')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: getInputDecoration("Nom"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: getInputDecoration("Edat"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: getInputDecoration("Correu electrònic"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: getInputDecoration("Contrasenya"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: getInputDecoration("Localització"),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                const Text("Rol: "),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: role,
                    items: const [
                      DropdownMenuItem(
                        value: 'worker',
                        child: Text('Treballador'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Administrador'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          role = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(onPressed: saveWorker, child: Text("Guardar")),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.profile),
              child: Text("Exit"),
            ),
          ],
        ),
      ),
    );
  }
}
