// screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:momentum/controllers/req_appointmentscreen_controller.dart';

class ReqAppointmentscreen extends StatelessWidget {
  final ReqAppointmentscreenController controller = Get.put(ReqAppointmentscreenController());

  ReqAppointmentscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        title: const Text(
          'Seleccionar cita',
          style: TextStyle(color: Colors.blue),
        ),
      ),
      body: Column(
        children: [
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              "Desde:",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            Text(
                              "${controller.date1.value.day.toString().padLeft(2, '0')}/${controller.date1.value.month.toString().padLeft(2, '0')}/${controller.date1.value.year}",
                              style: const TextStyle(fontSize: 16, color: Colors.blue),
                            ),
                            _styledButton("Desde", () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: controller.date1.value,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Colors.blue,
                                        onPrimary: Colors.white,
                                        onSurface: Colors.blue,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) controller.date1.value = picked;
                            }),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              "Hasta:",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            Text(
                              "${controller.date2.value.day.toString().padLeft(2, '0')}/${controller.date2.value.month.toString().padLeft(2, '0')}/${controller.date2.value.year}",
                              style: const TextStyle(fontSize: 16, color: Colors.blue),
                            ),
                            _styledButton("Hasta", () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: controller.date2.value,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Colors.blue,
                                        onPrimary: Colors.white,
                                        onSurface: Colors.blue,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) controller.date2.value = picked;
                            }),
                          ],
                        ),
                        _styledButton("Buscar", controller.fetchSlots),
                      ],
                    ),
                  ],
                ),
              )),
          Expanded(
            child: Obx(() => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : SfCalendar(
                    view: _getOptimalCalendarView(controller.date1.value, controller.date2.value),
                    initialDisplayDate: controller.date1.value,
                    minDate: controller.date1.value,
                    maxDate: controller.date2.value,
                    dataSource: _getDataSource(controller.slots),
                    backgroundColor: Colors.white,
                    showNavigationArrow: true,
                    showCurrentTimeIndicator: true,
                    headerStyle: const CalendarHeaderStyle(
                      textStyle: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    viewHeaderStyle: const ViewHeaderStyle(
                      backgroundColor: Colors.white,
                      dayTextStyle: TextStyle(color: Colors.blue),
                      dateTextStyle: TextStyle(color: Colors.blue),
                    ),
                    timeSlotViewSettings: const TimeSlotViewSettings(
                      startHour: 9,
                      endHour: 22,
                      timeIntervalHeight: 60,
                      timeFormat: 'HH:mm',
                      timeInterval: Duration(hours: 1),
                      timeTextStyle: TextStyle(color: Colors.blue),
                      dayFormat: 'EEE',
                      dateFormat: 'd',
                    ),
                    selectionDecoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: Colors.blue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    appointmentTextStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    appointmentBuilder: (context, calendarAppointmentDetails) {
                      final Appointment appointment = calendarAppointmentDetails.appointments.first;
                      return Container(
                        decoration: BoxDecoration(
                          color: appointment.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          appointment.subject,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                    onTap: (details) {
                      if (details.appointments != null && details.appointments!.isNotEmpty) {
                        final selected = details.appointments!.first;
                        _showConfirmationDialog(context, selected);
                      }
                    },
                  )),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar cita'),
          backgroundColor: Colors.white,
          content: Text(
            '¿Deseas reservar la cita para:\n'
            '${appointment.startTime.day}/${appointment.startTime.month}/${appointment.startTime.year}\n'
            'De ${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')} '
            'a ${appointment.endTime.hour.toString().padLeft(2, '0')}:${appointment.endTime.minute.toString().padLeft(2, '0')}?',
            style: const TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop();
                controller.requestAppointmentToWorker(appointment);
              },
            ),
          ],
        );
      },
    );
  }

  CalendarView _getOptimalCalendarView(DateTime date1, DateTime date2) {
    final difference = date2.difference(date1).inDays;
    if (difference <= 1) {
      return CalendarView.day;
    } else if (difference <= 7) {
      return CalendarView.week;
    } else if (difference <= 31) {
      return CalendarView.timelineWeek;
    } else {
      return CalendarView.month;
    }
  }

  _CalendarDataSource _getDataSource(List<Appointment> appointments) {
    return _CalendarDataSource(appointments);
  }
}

class _CalendarDataSource extends CalendarDataSource {
  _CalendarDataSource(List<Appointment> source) {
    appointments = source;
  }
}

Widget _styledButton(String text, VoidCallback onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    onPressed: onPressed,
    child: Text(text),
  );
}
