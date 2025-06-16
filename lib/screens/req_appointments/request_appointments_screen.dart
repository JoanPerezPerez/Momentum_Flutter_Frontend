// screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:momentum/controllers/req_appointmentscreen_controller.dart';

class ReqAppointmentscreen extends StatelessWidget {
  final ReqAppointmentscreenController controller = Get.put(ReqAppointmentscreenController());
  

   ReqAppointmentscreen({super.key}) {
    // La inicialización se maneja en el controlador onInit()
    // No necesitamos hacer nada aquí ya que onInit() se ejecuta automáticamente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar cita')),
      body: Column(
        children: [
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Desde: ${controller.date1.value.toLocal().toString().split(' ')[0]}"),
                  Text("Hasta: ${controller.date2.value.toLocal().toString().split(' ')[0]}"),
                ],
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                child: const Text("Desde"),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.date1.value,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    controller.date1.value = picked;
                  }
                },
              ),
              ElevatedButton(
                child: const Text("Hasta"),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.date2.value,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    controller.date2.value = picked;
                  }
                },
              ),
              ElevatedButton(
                child: const Text("Buscar"),
                onPressed: controller.fetchSlots,
              ),
            ],
          ),
          Expanded(
            child: Obx(() => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : SfCalendar(
                    view: _getOptimalCalendarView(controller.date1.value, controller.date2.value),
                    initialDisplayDate: controller.date1.value,
                    minDate: controller.date1.value,
                    maxDate: controller.date2.value,
                    dataSource: _getDataSource(controller.slots),
                    // Configuración optimizada para slots de 1 hora
                    timeSlotViewSettings: const TimeSlotViewSettings(
                      timeIntervalHeight: 60, // Altura aumentada para mejor visualización
                      timeFormat: 'HH:mm',
                      timeInterval: Duration(hours: 1), // Intervalos de 1 hora
                    ),
                    // Configuración adicional
                    showNavigationArrow: true,
                    showCurrentTimeIndicator: true,
                    appointmentTextStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    onTap: (details) {
                      if (details.appointments != null &&
                          details.appointments!.isNotEmpty) {
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

  // Función para mostrar diálogo de confirmación antes de crear la cita
  void _showConfirmationDialog(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar cita'),
          content: Text(
            '¿Deseas reservar la cita para:\n'
            '${appointment.startTime.day}/${appointment.startTime.month}/${appointment.startTime.year}\n'
            'De ${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')} '
            'a ${appointment.endTime.hour.toString().padLeft(2, '0')}:${appointment.endTime.minute.toString().padLeft(2, '0')}?',
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop();
                controller.createAppointment(appointment);
              },
            ),
          ],
        );
      },
    );
  }

  // Función para determinar la vista óptima basada en el rango de fechas
  CalendarView _getOptimalCalendarView(DateTime date1, DateTime date2) {
    final difference = date2.difference(date1).inDays;
    
    if (difference <= 1) {
      // Si es 1 día o menos, usar vista de día
      return CalendarView.day;
    } else if (difference <= 7) {
      // Si es una semana o menos, usar vista semanal
      return CalendarView.week;
    } else if (difference <= 31) {
      // Si es un mes o menos, usar vista de timeline semanal para mejor visualización
      return CalendarView.timelineWeek;
    } else {
      // Para rangos más largos, usar vista mensual
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