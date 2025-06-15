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
  List<String> selectedLocationIds = [];

  String role = 'worker';
  String title = '';
  @override
  void initState() {
    super.initState();
    adminController.getAllLocationsOfBusiness();
    prepareText();
    if (adminController.isUpdate.value) {
      fillFieldsFromWorker(adminController.worker.value);
    }
  }

  void fillFieldsFromWorker(my_models.Worker worker) {
    nameController.text = worker.name;
    ageController.text = worker.age.toString();
    emailController.text = worker.mail;
    selectedLocationIds = List<String>.from(worker.location);
    setState(() {
      role = worker.role;
    });
  }

  void prepareText() {
    if (adminController.isUpdate.value)
      title = 'Worker Update';
    else
      title = 'Worker Registre';
  }

  InputDecoration getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.blue.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void saveWorker() {
    if (adminController.isUpdate.value) {
      String? id = adminController.worker.value.id as String;
      adminController.worker.value = my_models.Worker(
        id: id,
        name: nameController.text,
        mail: emailController.text,
        age: int.tryParse(ageController.text) ?? 0,
        role: role,
        location: selectedLocationIds,
      );
      adminController.updateWorker();
    } else {
      adminController.worker.value = my_models.Worker(
        name: nameController.text,
        mail: emailController.text,
        age: int.tryParse(ageController.text) ?? 0,
        role: role,
        location: selectedLocationIds,
        password: passwordController.text,
      );
      adminController.registerWorker();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
              enabled: !adminController.isUpdate.value,
            ),
            SizedBox(height: 12),
            Text(
              'Selecciona les localitzacions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                final locations = adminController.locations;
                return ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final location = locations[index];
                    final isSelected = selectedLocationIds.contains(
                      location.id,
                    );

                    return CheckboxListTile(
                      title: Text(location.nombre),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedLocationIds.add(location.id);
                          } else {
                            selectedLocationIds.remove(location.id);
                          }
                        });
                      },
                    );
                  },
                );
              }),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                const Text("Rol: "),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value:
                        (role == 'worker' || role == 'admin') ? role : 'worker',
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
