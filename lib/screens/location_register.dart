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
  final streetController = TextEditingController();
  final numberAndDistrictController = TextEditingController();
  final postalCodeController = TextEditingController();
  final cityController = TextEditingController();
  final phoneController = TextEditingController();

  final RxSet<locationServiceType> selectedServices =
      <locationServiceType>{}.obs;

  final List<LocationSchedule> schedule = [];
  bool _accessible = false;

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
    streetController.dispose();
    numberAndDistrictController.dispose();
    postalCodeController.dispose();
    cityController.dispose();
    phoneController.dispose();
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
/*
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
  }*/
  Widget _buildScheduleRow(int index) {
    final row = schedule[index];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: DropdownButtonFormField<String>(
              value: row.day,
              items: [
                'monday',
                'tuesday',
                'wednesday',
                'thursday',
                'friday',
                'saturday',
                'sunday',
              ]
                  .map((day) => DropdownMenuItem(
                        value: day,
                        child: Text(day.toUpperCase()),
                      ))
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
          SizedBox(
            width: 100,
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
          SizedBox(
            width: 100,
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
      ),
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
      
      final fullAddress = '${streetController.text.trim()}, '
      '${numberAndDistrictController.text.trim()}, '
      '${postalCodeController.text.trim()} '
      '${cityController.text.trim()}';

      final success = await adminController.registerLocationWithGeocoding(
        nombre: nombreController.text.trim(),
        phone: phoneController.text.trim(),
        address: fullAddress,
        serviceType: selectedServices.toList(),
        schedule: schedule,
        accessible: _accessible,
      );

      if (!success) return;
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
                  const SizedBox(height: 16),
                  const Text('Adreça:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: streetController,
                    decoration: const InputDecoration(labelText: 'Carrer'),
                    validator: (value) => (value == null || value.isEmpty) ? 'Requerit' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: numberAndDistrictController,
                    decoration: const InputDecoration(labelText: ' Número i districte o barri'),
                    validator: (value) => (value == null || value.isEmpty) ? 'Requerit' : null,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: postalCodeController,
                          decoration: const InputDecoration(labelText: 'Codi postal'),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              (value == null || value.isEmpty) ? 'Requerit' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: cityController,
                          decoration: const InputDecoration(labelText: 'Ciutat'),
                          validator: (value) =>
                              (value == null || value.isEmpty) ? 'Requerit' : null,
                        ),
                      ),
                    ],
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
                      icon: const Icon(Icons.add, color: Colors.blue),
                      label: const Text('Afegeix horari', style: TextStyle(color: Colors.blue)),
                      onPressed: _addScheduleRow,
                    ),
                  ),

                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.accessible, color: Colors.blue),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Disposa d\'accessibilitat',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Switch(
                          value: _accessible,
                          activeColor: Colors.blue,
                          onChanged: (value) {
                            setState(() {
                              _accessible = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: _submit,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
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