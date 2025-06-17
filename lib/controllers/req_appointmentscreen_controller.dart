import 'dart:ui';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Aunque no lo usas aquí directamente
import 'package:shared_preferences/shared_preferences.dart';
import '../services/calendar_service.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ReqAppointmentscreenController extends GetxController {
  final CalendarService service = CalendarService();

  var date1 = DateTime.now().obs;
  var date2 = DateTime.now().add(const Duration(days: 7)).obs;
  var isLoading = false.obs;

  var slots = <Appointment>[].obs;

  final userId = ''.obs;
  final locationId = ''.obs;
  final locationName = ''.obs; 

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args == null || !(args as Map).containsKey('locationId')) {
      Get.snackbar("Error", "Parámetros inválidos para la cita");
      return;
    }

    setParams(location: args['locationId'].toString(), locationName: args['locationName'].toString());
  }

  void setParams({required String location, required String locationName }) async {
    final prefs = await SharedPreferences.getInstance();
    userId.value = prefs.getString('userId') ?? '';
    locationId.value = location;
    this.locationName.value = locationName;


    if (userId.value.isEmpty) {
      Get.snackbar("Error", "ID de usuario no encontrado");
      return;
    }

    await fetchSlots();
  }

  Future<void> fetchSlots() async {
    isLoading.value = true;
    try {
      final commonSlots = await service.getCommonSlotsUserLocation(
        userId.value,
        locationId.value,
        date1.value.toIso8601String(),
        date2.value.toIso8601String(),
      );

      List<Appointment> processedSlots = [];

      for (var slot in commonSlots) {
        final workerId = slot[0].toString();
        final start = DateTime.parse(slot[1]);
        final end = DateTime.parse(slot[2]);

        DateTime currentStart = start;
        while (currentStart.add(const Duration(hours: 1)).isBefore(end) ||
            currentStart.add(const Duration(hours: 1)).isAtSameMomentAs(end)) {
          final currentEnd = currentStart.add(const Duration(hours: 1));

          processedSlots.add(Appointment(
            startTime: currentStart,
            endTime: currentEnd,
            subject: "Slot disponible",
            color: const Color.fromARGB(255, 0, 128, 0),
            notes: "slot_${currentStart.millisecondsSinceEpoch}|$workerId",
          ));
          
          currentStart = currentStart.add(const Duration(hours: 1));
        }
      }

      slots.value = processedSlots;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAppointment(Appointment appointment) async {
    try {
      final appointmentData = {
        'title': "Reserva de cita a ",
        'inTime': appointment.startTime.toIso8601String(),
        'outTime': appointment.endTime.toIso8601String(),
        'description': "Reserva vía common slots",
        'location': locationId.value,
        'userId': userId.value,
      };

      final calendarIdUser = await _getCalendarIdForUser(userId.value);

      await service.addAppointment(calendarIdUser, appointmentData);

      Get.snackbar("Éxito", "Cita creada correctamente");
      await fetchSlots();
    } catch (e) {
      Get.snackbar("Error", e.toString());
      print("Error creating appointment: $e");
    }
  }

  Future<String> _getCalendarIdForUser(String userId) async {
    try {
      final calendars = await service.getUserCalendars(userId);

      if (calendars.isEmpty) {
        throw Exception("No calendars found for user $userId");
      }

      final personalCalendar = calendars
          .where((calendar) => calendar.name == "Personal")
          .firstOrNull;

      return personalCalendar?.id ?? calendars.first.id;
    } catch (e) {
      print("Error getting calendar ID: $e");
      return userId;
    }
  }

  Future<String> _getCalendarIdForWorker(String workerId) async {
    try {
      final calendars = await service.getUserCalendars(workerId);

      if (calendars.isEmpty) {
        throw Exception("No calendars found for worker $workerId");
      }

      final workCalendar = calendars
          .where((calendar) => calendar.name == "Work")
          .firstOrNull;

      return workCalendar?.id ?? calendars.first.id;
    } catch (e) {
      print("Error getting calendar ID for worker: $e");
      return workerId;
    }
  }

  Future<void> requestAppointmentToWorker(Appointment appointment) async {
  try {
    // Extrae el workerId correcto del slot
    final workerIdFromNotes = appointment.notes?.split('|').last ?? '';
    if (workerIdFromNotes.isEmpty) {
      throw Exception("No se pudo obtener el ID del trabajador");
    }

    final appointmentData = {
      'title': "Reserva en ${locationName.value}",
      'inTime': appointment.startTime.toIso8601String(),
      'outTime': appointment.endTime.toIso8601String(),
      'description': "Petición de cita enviada por usuario",
      'location': locationId.value,
      'userId': userId.value,
    };

    final calendarIdUser = await _getCalendarIdForUser(userId.value);

    await service.setAppointmentRequestForWorker(
      calendarId: calendarIdUser,
      workerId: workerIdFromNotes,
      appointment: appointmentData,
    );

    Get.snackbar("Éxito", "Petición de cita enviada correctamente");
    await fetchSlots();
  } catch (e) {
    Get.snackbar("Error", e.toString());
    print("Error enviando petición de cita: $e");
  }
}

}
