// controllers/calendar_controller.dart
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
  final businessId = ''.obs;
  final serviceType = ''.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args == null || !args.containsKey('businessId') || !args.containsKey('serviceType')) {
      Get.snackbar("Error", "Parámetros inválidos para la cita");
      return;
    }

    setParams(
      business: args['businessId'],
      service: args['serviceType'],
    );
  }

  void setParams({required String business, required String service}) async {
    final prefs = await SharedPreferences.getInstance();
    userId.value = prefs.getString('userId') ?? '';
    businessId.value = business;
    serviceType.value = service;

    if (userId.value.isEmpty) {
      Get.snackbar("Error", "ID de usuario no encontrado");
      return;
    }

    await fetchSlots(); // <- Ejecuta la carga automáticamente al tener los datos
  }

  Future<void> fetchSlots() async {
    isLoading.value = true;
    try {
      final commonSlots = await service.getCommonSlotsUserBussiness(
        userId.value,
        businessId.value,
        serviceType.value,
        date1.value.toIso8601String(),
        date2.value.toIso8601String(),
      );

      // Mapeo a Appointment de Syncfusion
      slots.value = commonSlots.expand((group) {
        final location = group[0];
        final calendarData = group[1] as List;
        return calendarData.expand((calendarEntry) {
          final calendarId = calendarEntry[0];
          final times = calendarEntry[1] as List;
          return times.map((timePair) {
            final start = DateTime.parse(timePair[0]);
            final end = DateTime.parse(timePair[1]);
            return Appointment(
              startTime: start,
              endTime: end,
              subject: "Disponible en $location",
              notes: calendarId,
              id: calendarId,
            );
          });
        });
      }).toList();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAppointment(Appointment appointment) async {
    try {
      await service.addAppointment(
        appointment.notes ?? '', // calendarId
        {
          "inTime": appointment.startTime.toIso8601String(),
          "outTime": appointment.endTime.toIso8601String(),
          "title": "Cita reservada",
          "serviceType": serviceType.value,
        },
      );
      Get.snackbar("Éxito", "Cita creada correctamente");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}

