import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/controllers/calendar_controller.dart';
import 'package:momentum/models/appointment_model.dart';
import 'package:momentum/routes/app_routes.dart';
import 'package:momentum/services/IA_service.dart';

class OptimizationController extends GetxController {
  var textToSend = '';
  var answerFromIA = ''.obs;
  var appointmentsFromIA = <AppointmentModel>[].obs;
  var isLoading = false.obs;
  final AuthController authController = Get.find<AuthController>();
  final CalendarController calendarController = Get.find<CalendarController>();

  Future<void> sendTestMesage() async {
    isLoading.value = true;
    try {
      var reponse = await IaService.test(textToSend);
      answerFromIA.value = reponse;
    } catch (e) {
      Get.snackbar("Error", "Login failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "(Sense hora)";
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String _formatDateDay(DateTime? dateTime) {
    if (dateTime == null) return "(Sense hora)";
    return "${dateTime.day.toString().padLeft(2, '0')}";
  }

  void showAnswerToUser() {
    if (appointmentsFromIA.isEmpty) {
      answerFromIA.value = "";
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln("L'horari que ha tornat la IA és el següent:\n");
    var currentDay;
    for (final appointment in appointmentsFromIA) {
      final inTimeStr = _formatDateTime(appointment.inTime);
      final outTimeStr = _formatDateTime(appointment.outTime);
      final appointmentDay = _formatDateDay(appointment.inTime);
      if (appointmentDay != currentDay) {
        if (currentDay != null) buffer.writeln("demà, dia  $appointmentDay");
        currentDay = appointmentDay;
      }
      final desc = appointment.description ?? "Appointment genèric";
      buffer.writeln("- $desc des de les $inTimeStr fins les $outTimeStr");
    }
    answerFromIA.value = buffer.toString();
  }

  Future<void> sendMessageToBackend() async {
    isLoading.value = true;
    try {
      var response = await IaService.sendOptimization(
        textToSend,
        authController.currentUser.value.id as String,
      );
      appointmentsFromIA.assignAll(response);
      showAnswerToUser();
    } catch (e) {
      Get.snackbar("Error", "Optimization failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> showAppointmentsInCalendar() async {
    calendarController.optimizedStandByAppointments.assignAll(
      appointmentsFromIA,
    );
    calendarController.allAppointments.addAll(appointmentsFromIA);
    calendarController.forceRefresh.value++;
    Get.toNamed(AppRoutes.calendar);
  }
}
