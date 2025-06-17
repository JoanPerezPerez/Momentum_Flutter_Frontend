import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:momentum/models/calendar_model.dart';
import 'package:momentum/services/calendar_service.dart';
import 'package:get/get.dart';
class ManageCalendarsScreen extends StatefulWidget {
  final String userId;

  const ManageCalendarsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ManageCalendarsScreen> createState() => _ManageCalendarsScreenState();
}

class _ManageCalendarsScreenState extends State<ManageCalendarsScreen> {
  List<CalendarModel> calendars = [];
  final TextEditingController calendarNameController = TextEditingController();
  bool isLoading = true;

  Color selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    fetchCalendars();
  }

  Future<void> fetchCalendars() async {
    setState(() => isLoading = true);
    try {
      calendars = await CalendarService().getUserCalendars(widget.userId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los calendarios: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> createCalendar() async {
    final name = calendarNameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        'Error',
        'El nombre del calendario no puede estar vacío',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final colorHex = '#${selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
      await CalendarService().createCalendar(name, widget.userId, colorHex);
      calendarNameController.clear();
      selectedColor = Colors.blue;
      await fetchCalendars();
      Get.snackbar('Éxito', 'Calendario creado correctamente', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo crear el calendario: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecciona un color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) => setState(() => selectedColor = color),
            enableAlpha: false,
            labelTypes: const [ColorLabelType.hex],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        title: const Text(
          'Crear Calendario',
          style: TextStyle(color: Colors.blue),
        ),
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Crear nuevo calendario:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: calendarNameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del calendario',
                      hintText: 'Ej: Personal, Trabajo, Estudios...',
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => createCalendar(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Color por defecto:', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _showColorPicker,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: selectedColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.black26),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '#${selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: createCalendar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'CREAR CALENDARIO',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Calendarios existentes:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: calendars.isEmpty
                        ? Center(
                            child: Text(
                              'No hay calendarios creados',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          )
                        : ListView.separated(
                            itemCount: calendars.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final calendar = calendars[index];
                              return ListTile(
                                title: Text(
                                  calendar.name,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text('ID: ${calendar.id}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (calendar.defaultColour != null)
                                      Icon(
                                        Icons.circle,
                                        color: Color(
                                          int.parse(
                                            calendar.defaultColour!.replaceFirst('#', '0xFF'),
                                          ),
                                        ),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      onPressed: () async {
                                        try {
                                          await CalendarService().softDeleteCalendar(calendar.id);
                                          await fetchCalendars();
                                          Get.snackbar('Éxito', 'Calendario eliminado');
                                        } catch (e) {
                                          Get.snackbar('Error', 'No se pudo eliminar el calendario: $e');
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
