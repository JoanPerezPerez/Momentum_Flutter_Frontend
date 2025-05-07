import 'package:flutter/material.dart';
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
        snackPosition: SnackPosition.BOTTOM
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
        snackPosition: SnackPosition.BOTTOM
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await CalendarService().createCalendar(name, widget.userId);
      calendarNameController.clear();
      await fetchCalendars();
      Get.snackbar(
        'Éxito', 
        'Calendario creado correctamente',
        snackPosition: SnackPosition.BOTTOM
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear el calendario: $e',
        snackPosition: SnackPosition.BOTTOM
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Calendario'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: calendarNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del calendario',
                      border: OutlineInputBorder(),
                      hintText: 'Ej: Personal, Trabajo, Estudios...',
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => createCalendar(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: createCalendar,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: calendars.isEmpty
                        ? Center(
                            child: Text(
                              'No hay calendarios creados',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: calendars.length,
                            separatorBuilder: (context, index) => Divider(),
                            itemBuilder: (context, index) {
                              final calendar = calendars[index];
                              return ListTile(
                                title: Text(
                                  calendar.name,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text('ID: ${calendar.id}'),
                                trailing: Icon(Icons.check_circle, color: Colors.green),
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
