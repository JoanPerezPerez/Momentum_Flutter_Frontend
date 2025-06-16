import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/controllers/recordatoris_controller.dart';
import 'package:momentum/models/recordatoris_model.dart';

class RecordatorisScreen extends StatelessWidget {
  final RecordatorisController controller = Get.find<RecordatorisController>();
  final AuthController authController = Get.find<AuthController>();
  RecordatorisScreen({super.key});
  @override
  Widget build(BuildContext context) {
    controller.fetchRecordatoris();
    return Scaffold(
      appBar: AppBar(title: const Text('Recordatoris')),
      body: Obx(() {
        final recordatoris = controller.recordatoris;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: recordatoris.length,
          itemBuilder: (context, index) {
            final rec = recordatoris[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  rec.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rec.description),
                    const SizedBox(height: 4),
                    Text(
                      'Data: ${DateFormat.yMd().add_Hm().format(rec.time.add(Duration(hours: 2)))}',
                    ),
                    Text('Repetició: ${rec.repeat.name}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => controller.deleteRecordatori(rec.id),
                ),
                onTap: () => _showAddOrEditDialog(context, rec),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditDialog(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddOrEditDialog(BuildContext context, Recordatori? existing) {
    final isEdit = existing != null;
    final titleCtrl = TextEditingController(text: existing?.title);
    final descCtrl = TextEditingController(text: existing?.description);
    DateTime selectedDate = existing?.time ?? DateTime.now();
    RepetitionType repeatType = existing?.repeat ?? RepetitionType.never;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isEdit ? 'Edita recordatori' : 'Nou recordatori'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Títol'),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Descripció'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Data: '),
                      Text(DateFormat.yMd().add_Hm().format(selectedDate)),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDate),
                            );
                            if (time != null) {
                              selectedDate = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                              (context as Element).markNeedsBuild();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<RepetitionType>(
                    value: repeatType,
                    onChanged: (value) {
                      if (value != null) {
                        repeatType = value;
                        (context as Element).markNeedsBuild();
                      }
                    },
                    items:
                        RepetitionType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.name),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel·la'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty) {
                    if (isEdit) {
                      controller.recordatori.value = Recordatori(
                        id: existing.id,
                        title: titleCtrl.text,
                        description: descCtrl.text,
                        userId: existing.userId,
                        time: selectedDate.subtract(const Duration(hours: 2)),
                        repeat: repeatType,
                      );
                      controller.updateRecordatori();
                    } else {
                      controller.recordatori.value = Recordatori(
                        id: '',
                        title: titleCtrl.text,
                        description: descCtrl.text,
                        userId: authController.currentUser.value.id as String,
                        time: selectedDate.subtract(const Duration(hours: 2)),
                        repeat: repeatType,
                      );
                      controller.addRecordatori();
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(isEdit ? 'Desa' : 'Afegeix'),
              ),
            ],
          ),
    );
  }
}
