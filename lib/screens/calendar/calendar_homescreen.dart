import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/screens/calendar/manage_calendars_screen.dart';
import 'package:momentum/services/calendar_service.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as flutter_selection;
import 'package:momentum/controllers/calendar_controller.dart' as MomentumCalendarController;
import 'package:momentum/models/calendar_model.dart';
import 'package:momentum/models/appointment_model.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  final String userId;

  const CalendarScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final MomentumCalendarController.CalendarController controller = Get.put(MomentumCalendarController.CalendarController(calendarService: Get.find()));
  final TextEditingController nameController = TextEditingController();
  final RxString selectedCalendarId = ''.obs;
  final Rx<flutter_selection.CalendarView> calendarView = flutter_selection.CalendarView.month.obs;
  List<CalendarModel> calendars = [];
  List<AppointmentModel> allAppointments = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    // Cargar calendarios al iniciar
    controller.fetchCalendars(widget.userId);
    // Cargar todas las citas al iniciar
    fetchAllAppointments();
  }

  // Método para cargar todas las citas de todos los calendarios
  Future<void> fetchAllAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      await controller.fetchAllAppointments(widget.userId);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar todas las citas: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCalendarsAndAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedCalendars = await CalendarService().getUserCalendars(widget.userId);
      final allAppointmentsTemp = <AppointmentModel>[];

      for (final calendar in fetchedCalendars) {
        final appointments = await CalendarService().getAllAppointments(calendar.id);
        allAppointmentsTemp.addAll(appointments);
      }

      setState(() {
        calendars = fetchedCalendars;
        allAppointments = allAppointmentsTemp;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void goToManageCalendarsScreen() {
    Get.to(() => ManageCalendarsScreen(userId: widget.userId))?.then((_) {
      // Refrescar al volver
      fetchCalendarsAndAppointments();
      fetchAllAppointments();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendarios'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              goToManageCalendarsScreen();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            if (controller.calendars.isNotEmpty)
              Expanded(
                flex: 1,
                child: ListView.builder(
                  itemCount: controller.calendars.length,
                  itemBuilder: (context, index) {
                    final calendar = controller.calendars[index];
                    return Obx(() => Card(
                          color: selectedCalendarId.value == calendar.id
                              ? Colors.lightBlue.shade50
                              : null,
                          child: ListTile(
                            title: Text(calendar.name),
                            subtitle: Text('ID: ${calendar.id}'),
                            onTap: () async {
                              controller.selectCalendar(calendar.id); // Usar método mejorado del controller
                              selectedCalendarId.value = calendar.id; // Actualizar ID local
                            },
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'soft') {
                                  await controller.softDeleteCalendar(calendar.id);
                                  fetchAllAppointments(); // Refrescar todas las citas
                                } else if (value == 'hard') {
                                  await controller.hardDeleteCalendar(calendar.id);
                                  fetchAllAppointments(); // Refrescar todas las citas
                                } else if (value == 'restore') {
                                  await controller.restoreCalendar(calendar.id);
                                  fetchAllAppointments(); // Refrescar todas las citas
                                } else if (value == 'edit') {
                                  _showEditCalendarDialog(context, calendar);
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(value: 'edit', child: Text('Editar')),
                                PopupMenuItem(value: 'soft', child: Text('Eliminar (soft)')),
                                PopupMenuItem(value: 'restore', child: Text('Restaurar')),
                                PopupMenuItem(value: 'hard', child: Text('Eliminar permanente')),
                              ],
                            ),
                          ),
                        ));
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Vista: '),
                  SizedBox(width: 8),
                  Obx(() => DropdownButton<flutter_selection.CalendarView>(
                        value: calendarView.value,
                        onChanged: (view) {
                          if (view != null) {
                            calendarView.value = view;
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: flutter_selection.CalendarView.month,
                            child: Text('Mes'),
                          ),
                          DropdownMenuItem(
                            value: flutter_selection.CalendarView.week,
                            child: Text('Semana'),
                          ),
                          DropdownMenuItem(
                            value: flutter_selection.CalendarView.workWeek,
                            child: Text('Semana laboral'),
                          ),
                          DropdownMenuItem(
                            value: flutter_selection.CalendarView.day,
                            child: Text('Día'),
                          ),
                        ],
                      )),
                ],
              ),
            ),
            Obx(() {
              // Convertir las citas al formato de Syncfusion
              final meetings = _getAllCalendarAppointments();

              return Expanded(
                flex: 3,
                child: flutter_selection.SfCalendar(
                  key: Key('calendar_${controller.forceRefresh}'),
                  view: calendarView.value,
                  dataSource: _AppointmentDataSource(meetings),
                  firstDayOfWeek: 1, // Lunes
                  showNavigationArrow: true,
                  allowViewNavigation: true,
                  showDatePickerButton: true,
                  todayHighlightColor: Colors.blue,
                  initialSelectedDate: controller.selectedDay.value, // Fecha inicial
                  onTap: (flutter_selection.CalendarTapDetails details) {
                    if (details.targetElement == flutter_selection.CalendarElement.calendarCell) {
                      if (details.date != null) {
                        controller.selectedDay.value = details.date!; // Actualizar la fecha en el controlador
                        controller.forceRefresh.value++; // Forzar actualización del calendario
                        
                        // Si hay un calendario seleccionado, cargar sus citas para este día
                        if (selectedCalendarId.value.isNotEmpty) {
                          controller.loadAppointments(
                            selectedCalendarId.value,
                            DateFormat('yyyy-MM-dd').format(details.date!)
                          );
                        }
                      }
                    } else if (details.targetElement == flutter_selection.CalendarElement.appointment) {
                      // Mostrar detalles de la cita al hacer clic en ella
                      if (details.appointments != null && details.appointments!.isNotEmpty) {
                        _showAppointmentDetails(context, details.appointments!.first as flutter_selection.Appointment);
                      }
                    }
                  },
                  selectionDecoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  monthViewSettings: flutter_selection.MonthViewSettings(
                    showAgenda: true,
                    agendaViewHeight: 200,
                    appointmentDisplayMode: flutter_selection.MonthAppointmentDisplayMode.appointment,
                    agendaStyle: flutter_selection.AgendaStyle(
                      backgroundColor: Colors.white,
                      appointmentTextStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      dateTextStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.black54,
                      ),
                      dayTextStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  appointmentBuilder: (context, calendarAppointmentDetails) {
                    final flutter_selection.Appointment appointment = calendarAppointmentDetails.appointments.first;
                    return Container(
                      decoration: BoxDecoration(
                        color: appointment.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        appointment.subject,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        );
      }),
      floatingActionButton: Obx(() => selectedCalendarId.value.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showAddAppointmentDialog(context),
              child: Icon(Icons.add),
              tooltip: 'Añadir cita',
            )
          : Container()),
    );
  }

  // Método actualizado para obtener todas las citas de todos los calendarios
  List<flutter_selection.Appointment> _getAllCalendarAppointments() {
    List<flutter_selection.Appointment> appointments = [];
    
    // Primero agregamos todas las citas de todos los calendarios
    for (var app in controller.allAppointments) {
      final DateTime startTime = app.inTime;
      final DateTime endTime = app.outTime;
      appointments.add(
        flutter_selection.Appointment(
          id: app.id,
          subject: app.title,
          startTime: startTime,
          endTime: endTime,
          color: Colors.grey, // Color para citas de calendarios no seleccionados
          notes: app.description,
          location: app.locationId,
          recurrenceRule: '',
          isAllDay: false,
        ),
      );
    }
    
    // Si hay un calendario seleccionado, destacamos sus citas con un color diferente
    if (selectedCalendarId.value.isNotEmpty) {
      for (var app in controller.appointments) {
        final DateTime startTime = app.inTime;
        final DateTime endTime = app.outTime;
        
        // Intentamos encontrar la cita en la lista general para actualizarla
        int index = appointments.indexWhere((appt) => appt.id == app.id);
        
        if (index >= 0) {
          // Actualizar la cita existente con un color destacado
          appointments[index] = flutter_selection.Appointment(
            id: app.id,
            subject: app.title,
            startTime: startTime,
            endTime: endTime,
            color: Colors.blue, // Color para citas del calendario seleccionado
            notes: app.description,
            location: app.locationId,
            recurrenceRule: '',
            isAllDay: false,
          );
        }
      }
    }
    
    return appointments;
  }

  // Método original para obtener citas del calendario seleccionado
  List<flutter_selection.Appointment> _getCalendarAppointments() {
    List<flutter_selection.Appointment> appointments = [];
    for (var app in controller.appointments) {
      final DateTime startTime = app.inTime;
      final DateTime endTime = app.outTime;
      appointments.add(
        flutter_selection.Appointment(
          id: app.id,
          subject: app.title,
          startTime: startTime,
          endTime: endTime,
          color: Colors.blue,
          notes: app.description,
          location: app.locationId,
          // Guardar la referencia al modelo original para acceder a sus datos
          recurrenceRule: '',
          isAllDay: false,
        ),
      );
    }
    return appointments;
  }

  String _formatTime(String dateTimeStr) {
    final dateTime = DateTime.parse(dateTimeStr);
    return DateFormat('HH:mm').format(dateTime);
  }

  void _showAppointmentDetails(BuildContext context, flutter_selection.Appointment appointment) {
    Get.dialog(
      AlertDialog(
        title: Text('Detalles de la cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Título: ${appointment.subject}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Inicio: ${DateFormat('dd/MM/yyyy HH:mm').format(appointment.startTime)}'),
            Text('Fin: ${DateFormat('dd/MM/yyyy HH:mm').format(appointment.endTime)}'),
            if (appointment.notes != null && appointment.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('Descripción: ${appointment.notes}'),
              ),
            if (appointment.location != null && appointment.location!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('Ubicación: ${appointment.location}'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              // Lógica para eliminar cita
              Get.back();
              Get.snackbar(
                'Información',
                'Función de eliminar cita no implementada',
                snackPosition: SnackPosition.BOTTOM
              );
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog(BuildContext context) {
    if (selectedCalendarId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Selecciona un calendario primero',
        snackPosition: SnackPosition.BOTTOM
      );
      return;
    }

    final titleController = TextEditingController();
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Nueva cita'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Título'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: startTimeController,
                decoration: InputDecoration(labelText: 'Hora inicio (HH:MM)'),
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 10),
              TextField(
                controller: endTimeController,
                decoration: InputDecoration(labelText: 'Hora fin (HH:MM)'),
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Descripción (opcional)'),
                maxLines: 2,
              ),
              SizedBox(height: 10),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Ubicación (opcional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  startTimeController.text.isEmpty ||
                  endTimeController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Título y horarios son obligatorios',
                  snackPosition: SnackPosition.BOTTOM
                );
                return;
              }

              try {
                // Formatear fechas
                final dateStr = controller.selectedDay.value.toIso8601String().split('T')[0];
                final startDateTime = '${dateStr}T${startTimeController.text}:00';
                final endDateTime = '${dateStr}T${endTimeController.text}:00';

                final appointmentData = {
                  'title': titleController.text,
                  'inTime': startDateTime,
                  'outTime': endDateTime,
                  'description': descriptionController.text,
                  'location': locationController.text.isNotEmpty 
                    ? locationController.text 
                    : null,
                };

                await controller.addAppointment(selectedCalendarId.value, appointmentData);
                Get.back();
                
                // Recargar citas
                await controller.loadAppointments(
                  selectedCalendarId.value,
                  controller.selectedDay.value.toIso8601String().split('T').first,
                );
                
                // Recargar todas las citas para actualizar la vista
                fetchAllAppointments();
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'No se pudo crear la cita: $e',
                  snackPosition: SnackPosition.BOTTOM
                );
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditCalendarDialog(BuildContext context, CalendarModel calendar) {
    final nameController = TextEditingController(text: calendar.name);

    Get.dialog(
      AlertDialog(
        title: Text('Editar calendario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'El nombre no puede estar vacío',
                  snackPosition: SnackPosition.BOTTOM
                );
                return;
              }

              try {
                await controller.editCalendar(calendar.id, {'calendarName': nameController.text});
                Get.back();
                // Recargar calendarios
                await controller.fetchCalendars(widget.userId);
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'No se pudo editar el calendario: $e',
                  snackPosition: SnackPosition.BOTTOM
                );
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _AppointmentDataSource extends flutter_selection.CalendarDataSource {
  _AppointmentDataSource(List<flutter_selection.Appointment> source) {
    appointments = source;
  }
}

