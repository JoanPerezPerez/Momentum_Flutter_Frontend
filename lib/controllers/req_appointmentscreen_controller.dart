// controllers/calendar_controller.dart
import 'dart:ui';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
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

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args == null || !args.containsKey('locationId')) {
      Get.snackbar("Error", "Parámetros inválidos para la cita");
      return;
    }

    setParams(
      location: args['locationId'].toString(), // <- Convertir a String aquí también
      
    );
  }

  void setParams({required String location}) async {
    final prefs = await SharedPreferences.getInstance();
    userId.value = prefs.getString('userId') ?? '';
    locationId.value = location;
    

    if (userId.value.isEmpty) {
      Get.snackbar("Error", "ID de usuario no encontrado");
      return;
    }

    await fetchSlots(); // <- Ejecuta la carga automáticamente al tener los datos
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

      // Modificación: Crear slots de exactamente 1 hora cada uno
      List<Appointment> processedSlots = [];
      
      for (var slot in commonSlots) {
        final start = DateTime.parse(slot[0]);
        final end = DateTime.parse(slot[1]);
        
        // Calcular cuántos slots de 1 hora caben en est rango
        DateTime currentStart = start;
        while (currentStart.add(const Duration(hours: 1)).isBefore(end) || 
               currentStart.add(const Duration(hours: 1)).isAtSameMomentAs(end)) {
          
          final currentEnd = currentStart.add(const Duration(hours: 1));
          
          processedSlots.add(Appointment(
            startTime: currentStart,
            endTime: currentEnd,
            subject: "Slot disponible",
            color: const Color.fromARGB(255, 0, 128, 0), // Verde
            notes: "slot_${currentStart.millisecondsSinceEpoch}", // Identificador único simple
          ));
          
          // Avanzar al siguiente slot de 1 hora
          currentStart = currentStart.add(const Duration(hours: 1));
        }
      }

      slots.value = processedSlots;

      print("CARGADOS ${slots.value.length} slots de 1 hora: ${slots.value.map((e) => '${e.startTime} → ${e.endTime}').join(', ')}");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAppointment(Appointment appointment) async {
    try {
      final appointmentData = {
        'title': "Reserva de cita",
        'inTime': appointment.startTime.toIso8601String(),
        'outTime': appointment.endTime.toIso8601String(),
        'description': "Reserva vía common slots",
        'location': locationId.value,
        'userId': userId.value,
      };
      
      final calendarIduser = await _getCalendarIdForUser(userId.value);

      /*final calendarIdworker = await _getCalendarIdForUser(locationId.value);*/
      await service.addAppointment(
        calendarIduser,
        appointmentData
      );
      /*await service.addAppointment(
        calendarIdworker,
        appointmentData
      );*/
      
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
      
      final personalCalendar = calendars.where((calendar) => calendar.name == "Personal").firstOrNull;
      
      if (personalCalendar != null) {
        //print("Calendar ID for user $userId: ${personalCalendar.id}");
        return personalCalendar.id;
      } else {

        final firstCalendar = calendars.first;
        //print("Personal calendar not found, using first available calendar: ${firstCalendar.id}");
        return firstCalendar.id;
      }
      
    } catch (e) {
      //print("Error getting calendar ID: $e");

      return userId;
    }
  }

  Future<String> _getCalendarIdForWorker(String workerId) async {
  try {

    final calendars = await service.getUserCalendars(workerId);
    
    if (calendars.isEmpty) {
      throw Exception("No calendars found for worker $workerId");
    }
    

    final workCalendar = calendars.where((calendar) => calendar.name == "Work").firstOrNull;
    
    if (workCalendar != null) {
      //print("Calendar ID for worker $workerId: ${workCalendar.id}");
      return workCalendar.id;
    } else {

      final firstCalendar = calendars.first;
      //print("Work calendar not found, using first available calendar: ${firstCalendar.id}");
      return firstCalendar.id;
    }
    
  } catch (e) {
    //print("Error getting calendar ID for worker: $e");

    return workerId;
  }
}
}
