import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:momentum/models/calendar_model.dart';
import 'package:momentum/models/appointment_model.dart';
import 'package:momentum/services/calendar_service.dart';

class CalendarController extends GetxController {
  final CalendarService _calendarService;
  final RxString selectedCalendarId = ''.obs;
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final RxInt forceRefresh = 0.obs;
  final RxList<CalendarModel> calendars = <CalendarModel>[].obs;
  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> allAppointments = <AppointmentModel>[].obs;
  final RxBool isLoading = false.obs;

  CalendarController({required CalendarService calendarService}) : _calendarService = calendarService;

  List<CalendarModel> userCalendars = [];
  Map<DateTime, List<AppointmentModel>> appointmentsByDay = {};
  DateTime selectedDate = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    const String userId = 'user1'; // Reemplazar con lógica real de usuario
    await loadAllAppointments(userId);
  }

  Future<void> loadAllAppointments(String userId) async {
    userCalendars = await _calendarService.getUserCalendars(userId);
    final Map<DateTime, List<AppointmentModel>> grouped = {};

    for (var calendar in userCalendars) {
      final appointments = await _calendarService.getAllAppointments(calendar.id);

      for (var appointment in appointments) {
        final date = appointment.inTime.toLocal();
        final key = DateTime(date.year, date.month, date.day);
        grouped.putIfAbsent(key, () => []);
        grouped[key]!.add(appointment);
      }
    }

    appointmentsByDay = grouped;
    update();
  }

  void onDateSelected(DateTime date) {
    selectedDate = date;
    update();
  }

  List<AppointmentModel> get selectedAppointments =>
      appointmentsByDay[selectedDate] ?? [];

  // Método para cargar todas las citas de todos los calendarios de un usuario
  Future<void> fetchAllAppointments(String userId) async {
    try {
      isLoading.value = true;
      final userCalendars = await _calendarService.getUserCalendars(userId);
      List<AppointmentModel> allAppointmentsTemp = [];
      
      for (var calendar in userCalendars) {
        final calendarAppointments = await _calendarService.getAllAppointments(calendar.id);
        allAppointmentsTemp.addAll(calendarAppointments);
      }
      
      allAppointments.assignAll(allAppointmentsTemp);
    } catch (e) {
      Get.snackbar('Error', 'Error al obtener todas las citas: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectCalendar(String calendarId) async {
    try {
      selectedCalendarId.value = calendarId;
      // Cargar citas para el día seleccionado
      await loadAppointments(
        calendarId, 
        DateFormat('yyyy-MM-dd').format(selectedDay.value)
      );
    } catch (e) {
      Get.snackbar('Error', 'Error al seleccionar calendario: $e');
    }
  }
  
  Future<void> updateSelectedDay(DateTime newDay) async {
    selectedDay.value = newDay;
    if (selectedCalendarId.isNotEmpty) {
      await loadAppointments(
        selectedCalendarId.value,
        DateFormat('yyyy-MM-dd').format(newDay)
      );
    }
  }
  
  // Cargar calendarios de un usuario
  Future<void> fetchCalendars(String userId) async {
    try {
      isLoading.value = true;
      final result = await _calendarService.getUserCalendars(userId);
      calendars.assignAll(result);
      
      // Si hay un calendario seleccionado, intentar mantenerlo
      if (selectedCalendarId.isNotEmpty) {
        // Verificar si el calendario seleccionado aún existe
        bool calendarStillExists = result.any((cal) => cal.id == selectedCalendarId.value);
        if (!calendarStillExists && result.isNotEmpty) {
          // Si el calendario ya no existe pero hay otros, seleccionar el primero
          await selectCalendar(result.first.id);
        } else if (!calendarStillExists) {
          // Si no queda ningún calendario, limpiar selección
          selectedCalendarId.value = '';
          appointments.clear();
        }
      }
      
      // Cargar todas las citas después de obtener los calendarios
      await fetchAllAppointments(userId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los calendarios: $e',
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Crear un nuevo calendario
  Future<void> createCalendar(String name, String userId) async {
    try {
      isLoading.value = true;
      final newCalendar = await _calendarService.createCalendar(name, userId);
      calendars.add(newCalendar);
      await selectCalendar(newCalendar.id);
      // Actualizar todas las citas
      await fetchAllAppointments(userId);
      Get.snackbar('Success', 'Calendar created');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create calendar: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Cargar citas para un día específico
  Future<void> loadAppointments(String calendarId, String date) async {
    try {
      isLoading.value = true;
      final result = await _calendarService.getAppointmentsByDate(calendarId, date);
      appointments.assignAll(result);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las citas: $e',
        snackPosition: SnackPosition.BOTTOM
      );
      appointments.clear();
    } finally {
      isLoading.value = false;
    }
  }
  
  // Añadir una cita al calendario
  Future<void> addAppointment(String calendarId, Map<String, dynamic> appointmentData) async {
    try {
      isLoading.value = true;
      
      // Asegurar que serviceType y appointmentState están en el formato correcto
      if (!appointmentData.containsKey('serviceType')) {
        appointmentData['serviceType'] = AppointmentServiceType.personal.toString().split('.').last.toLowerCase();
      }
      
      if (!appointmentData.containsKey('appointmentState')) {
        appointmentData['appointmentState'] = AppointmentState.requested.toString().split('.').last.toLowerCase();
      }
      
      final newAppointment = await _calendarService.addAppointment(calendarId, appointmentData);
      
      // Añadir la nueva cita directamente a la lista en memoria
      appointments.add(newAppointment);
      
      // También actualizar la lista completa de citas
      allAppointments.add(newAppointment);
      
      Get.snackbar(
        'Éxito',
        'Cita añadida correctamente',
        snackPosition: SnackPosition.BOTTOM
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo añadir la cita: $e',
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Editar una cita existente
  Future<void> editAppointment(String calendarId, String appointmentId, Map<String, dynamic> appointmentData) async {
    try {
      isLoading.value = true;
      
      // Implementar lógica para editar cita
      // Este método necesitaría ser implementado en CalendarService
      
      // Actualizar las listas locales
      await loadAppointments(calendarId, DateFormat('yyyy-MM-dd').format(selectedDay.value));
      await fetchAllAppointments('user1'); // Reemplazar con userId real
      
      Get.snackbar(
        'Éxito',
        'Cita actualizada correctamente',
        snackPosition: SnackPosition.BOTTOM
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la cita: $e',
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Eliminar una cita
  Future<void> deleteAppointment(String calendarId, String appointmentId) async {
    try {
      isLoading.value = true;
      
      // Este método necesitaría ser implementado en CalendarService
      
      // Actualizar las listas locales
      appointments.removeWhere((a) => a.id == appointmentId);
      allAppointments.removeWhere((a) => a.id == appointmentId);
      
      Get.snackbar(
        'Éxito',
        'Cita eliminada correctamente',
        snackPosition: SnackPosition.BOTTOM
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar la cita: $e',
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Cambiar el estado de una cita
  Future<void> changeAppointmentState(String calendarId, String appointmentId, AppointmentState newState) async {
    try {
      isLoading.value = true;
      
      // Este método necesitaría ser implementado en CalendarService
      
      // Actualizar las listas locales
      await loadAppointments(calendarId, DateFormat('yyyy-MM-dd').format(selectedDay.value));
      await fetchAllAppointments('user1'); // Reemplazar con userId real
      
      Get.snackbar(
        'Éxito',
        'Estado de la cita actualizado',
        snackPosition: SnackPosition.BOTTOM
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el estado de la cita: $e',
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Eliminar suave de un calendario
  Future<void> softDeleteCalendar(String calendarId) async {
    try {
      isLoading.value = true;
      await _calendarService.softDeleteCalendar(calendarId);
      
      // Obtener las citas de este calendario para eliminarlas de la lista completa
      final calendarAppointments = allAppointments.where((app) => app.id == calendarId).toList();
      
      // Actualizar la lista local eliminando el calendario
      calendars.removeWhere((calendar) => calendar.id == calendarId);
      
      // Eliminar las citas de este calendario de la lista completa
      for (var app in calendarAppointments) {
        allAppointments.removeWhere((appointment) => appointment.id == app.id);
      }
      
      // Si era el calendario seleccionado, limpiar selección o seleccionar otro
      if (selectedCalendarId.value == calendarId) {
        if (calendars.isNotEmpty) {
          await selectCalendar(calendars.first.id);
        } else {
          selectedCalendarId.value = '';
          appointments.clear();
        }
      }
      
      Get.snackbar(
        'Éxito',
        'Calendario eliminado correctamente',
        snackPosition: SnackPosition.BOTTOM
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el calendario: $e',
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Eliminar permanentemente un calendario
  Future<void> hardDeleteCalendar(String calendarId) async {
    try {
      isLoading.value = true;
      await _calendarService.hardDeleteCalendar(calendarId);
      
      // Actualizar la lista local de calendarios
      calendars.removeWhere((calendar) => calendar.id == calendarId);
      
      // Eliminar todas las citas de este calendario
      allAppointments.removeWhere((app) => app.id == calendarId);
      
      // Si era el calendario seleccionado, limpiar selección o seleccionar otro
      if (selectedCalendarId.value == calendarId) {
        if (calendars.isNotEmpty) {
          await selectCalendar(calendars.first.id);
        } else {
          selectedCalendarId.value = '';
          appointments.clear();
        }
      }
      
      Get.snackbar(
        'Éxito',
        'Calendario eliminado permanentemente',
        snackPosition: SnackPosition.BOTTOM
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar permanentemente el calendario: $e',
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Restaurar un calendario eliminado
  Future<void> restoreCalendar(String calendarId) async {
    try {
      isLoading.value = true;
      await _calendarService.restoreCalendar(calendarId);
      
      // Recargar los calendarios para incluir el restaurado
      const String userId = 'user1'; // Reemplazar con lógica real de usuario
      await fetchCalendars(userId);
      
      Get.snackbar(
        'Éxito',
        'Calendario restaurado correctamente',
        snackPosition: SnackPosition.BOTTOM
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo restaurar el calendario: $e',
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Editar un calendario
  Future<void> editCalendar(String calendarId, Map<String, dynamic> calendarData) async {
    try {
      isLoading.value = true;
      await _calendarService.editCalendar(calendarId, calendarData);
      
      // Actualizar el calendario en la lista local
      final index = calendars.indexWhere((cal) => cal.id == calendarId);
      if (index != -1) {
        final updatedCalendar = calendars[index].copyWith(
          name: calendarData['calendarName'] ?? calendars[index].name,
        );
        calendars[index] = updatedCalendar;
      }
      
      Get.snackbar(
        'Éxito',
        'Calendario actualizado correctamente',
        snackPosition: SnackPosition.BOTTOM
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el calendario: $e',
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Obtener slots comunes entre dos usuarios
  Future<List<List<String>>> getCommonSlotsTwoUsers(
      String user1Id, String user2Id, String startDate, String endDate) async {
    try {
      isLoading.value = true;
      return await _calendarService.getCommonSlotsTwoUsers(
        user1Id, user2Id, startDate, endDate);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron obtener los slots comunes: $e',
        snackPosition: SnackPosition.BOTTOM
      );
      return [];
    } finally {
      isLoading.value = false;
    }
  }
  
  // Obtener slots comunes entre múltiples usuarios
  Future<List<List<String>>> getCommonSlotsMultipleUsers(
      List<String> userIds, String startDate, String endDate) async {
    try {
      isLoading.value = true;
      return await _calendarService.getCommonSlotsMultipleUsers(
        userIds, startDate, endDate);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron obtener los slots comunes múltiples: $e',
        snackPosition: SnackPosition.BOTTOM
      );
      return [];
    } finally {
      isLoading.value = false;
    }
  }
}