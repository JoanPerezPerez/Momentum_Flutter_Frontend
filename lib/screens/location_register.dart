import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/admin_controller.dart';
import 'package:momentum/models/location_model.dart';

class RegisterLocationScreen extends StatefulWidget {
  const RegisterLocationScreen({super.key});

  @override
  State<RegisterLocationScreen> createState() => _RegisterLocationScreenState();
}

class _RegisterLocationScreenState extends State<RegisterLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminController adminController = Get.find<AdminController>();
  final nombreController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final latController = TextEditingController();
  final lonController = TextEditingController();

  final RxSet<locationServiceType> selectedServices =
      <locationServiceType>{}.obs;

  final List<LocationSchedule> schedule = [];

  void _addScheduleRow() {
    setState(() {
      schedule.add(
        LocationSchedule(
          day: 'monday',
          openingTime: '09:00',
          closingTime: '17:00',
        ),
      );
    });
  }

  void _removeScheduleRow(int index) {
    setState(() {
      schedule.removeAt(index);
    });
  }

  @override
  void dispose() {
    nombreController.dispose();
    addressController.dispose();
    phoneController.dispose();
    latController.dispose();
    lonController.dispose();
    super.dispose();
  }

  Widget _buildServiceTypeChips() {
    return Obx(
      () => Wrap(
        spacing: 6,
        children:
            locationServiceType.values.map((service) {
              final selected = selectedServices.contains(service);
              return FilterChip(
                label: Text(service.description),
                selected: selected,
                onSelected: (bool selectedNow) {
                  if (selectedNow) {
                    selectedServices.add(service);
                  } else {
                    selectedServices.remove(service);
                  }
                },
              );
            }).toList(),
      ),
    );
  }

  Widget _buildScheduleRow(int index) {
    final row = schedule[index];
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: row.day,
            items:
                [
                      'monday',
                      'tuesday',
                      'wednesday',
                      'thursday',
                      'friday',
                      'saturday',
                      'sunday',
                    ]
                    .map(
                      (day) => DropdownMenuItem(
                        value: day,
                        child: Text(day.toUpperCase()),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  schedule[index] = LocationSchedule(
                    day: value,
                    openingTime: row.openingTime,
                    closingTime: row.closingTime,
                  );
                });
              }
            },
            decoration: const InputDecoration(labelText: 'Dia'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: row.openingTime,
            decoration: const InputDecoration(labelText: 'Obre (HH:mm)'),
            onChanged: (val) {
              setState(() {
                schedule[index] = LocationSchedule(
                  day: row.day,
                  openingTime: val,
                  closingTime: row.closingTime,
                );
              });
            },
            validator: (value) {
              if (value == null || !RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
                return 'Format HH:mm';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: row.closingTime,
            decoration: const InputDecoration(labelText: 'Tanca (HH:mm)'),
            onChanged: (val) {
              setState(() {
                schedule[index] = LocationSchedule(
                  day: row.day,
                  openingTime: row.openingTime,
                  closingTime: val,
                );
              });
            },
            validator: (value) {
              if (value == null || !RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
                return 'Format HH:mm';
              }
              return null;
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _removeScheduleRow(index),
        ),
      ],
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (selectedServices.isEmpty) {
        Get.snackbar('Error', 'Selecciona almenys un tipus de servei');
        return;
      }
      if (schedule.isEmpty) {
        Get.snackbar('Error', 'Afegeix almenys un horari');
        return;
      }
      // Parse lat i lon
      final lat = double.tryParse(latController.text);
      final lon = double.tryParse(lonController.text);

      if (lat == null || lon == null) {
        Get.snackbar('Error', 'Latitud i longitud no vàlides');
        return;
      }

      adminController.location.value = ILocation(
        id: '',
        nombre: nombreController.text.trim(),
        address: addressController.text.trim(),
        phone: phoneController.text.trim(),
        rating: 0.0,
        ubicacion: GeoJSONPoint(type: 'Point', coordinates: [lon, lat]),
        serviceType: selectedServices.toList(),
        schedule: schedule,
        business: '',
        workers: [],
      );
      await adminController.registerLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registra Location')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Requerit'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Adreça'),
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Requerit'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Telèfon'),
                    keyboardType: TextInputType.phone,
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Requerit'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: latController,
                          decoration: const InputDecoration(
                            labelText: 'Latitud',
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null ||
                                double.tryParse(value) == null) {
                              return 'Num. vàlid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: lonController,
                          decoration: const InputDecoration(
                            labelText: 'Longitud',
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null ||
                                double.tryParse(value) == null) {
                              return 'Num. vàlid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Tipus de serveis:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildServiceTypeChips(),

                  const SizedBox(height: 24),
                  const Text(
                    'Horari:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  ...List.generate(
                    schedule.length,
                    (index) => _buildScheduleRow(index),
                  ),

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Afegeix horari'),
                      onPressed: _addScheduleRow,
                    ),
                  ),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Registrar Location',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
