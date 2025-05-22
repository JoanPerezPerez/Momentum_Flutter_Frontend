import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:momentum/models/calendar_model.dart';
import 'package:momentum/models/appointment_model.dart';
import 'package:momentum/services/calendar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarController extends GetxController {
  // Dependencies
  final CalendarService calendarService;
  
  // Observable state
  final userId = ''.obs;
  final selectedCalendarId = ''.obs;
  final selectedDay = DateTime.now().obs;
  final forceRefresh = 0.obs;
  final calendars = <CalendarModel>[].obs;
  final appointments = <AppointmentModel>[].obs;
  final allAppointments = <AppointmentModel>[].obs;
  final isLoading = false.obs;

  // Constructor with dependency injection
  CalendarController({CalendarService? service}) 
      : calendarService = service ?? CalendarService();

  @override
  void onInit() async {
    super.onInit();
    await _loadUserId();
    await _loadUserData();
  }

  // Private methods for internal use
  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId.value = prefs.getString('userId') ?? '';
      
      // If no user ID is found, use a fallback for development
      if (userId.isEmpty) {
        Get.snackbar('Error', 'Not possible to load userId'); // Fallback for development
      }
    } catch (e) {
      _handleError('Error loading user data', e);
      // Fallback on error
    }
  }

  Future<void> _loadUserData() async {
    if (userId.isEmpty) return;
    await fetchCalendars(userId.value);
    await fetchAllAppointments(userId.value);
  }

  void _handleError(String message, dynamic error) {
    Get.snackbar(
      'Error',
      '$message: $error',
      snackPosition: SnackPosition.BOTTOM
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Public API methods
  Future<void> fetchCalendars(String userId) async {
    try {
      isLoading.value = true;
      final result = await calendarService.getUserCalendars(userId);
      calendars.assignAll(result);
      
      // Handle selected calendar persistence
      if (selectedCalendarId.isNotEmpty) {
        final calendarExists = result.any((cal) => cal.id == selectedCalendarId.value);
        
        if (!calendarExists && result.isNotEmpty) {
          // Select first available calendar if current one doesn't exist
          await selectCalendar(result.first.id);
        } else if (!calendarExists) {
          // Clear selection if no calendars available
          selectedCalendarId.value = '';
          appointments.clear();
        }
      }
    } catch (e) {
      _handleError('Failed to load calendars', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllAppointments(String userId) async {
    try {
      isLoading.value = true;
      final userCalendars = await calendarService.getUserCalendars(userId);
      final allAppointmentsTemp = <AppointmentModel>[];
      
      for (final calendar in userCalendars) {
        final calendarAppointments = await calendarService.getAllAppointments(calendar.id);
        allAppointmentsTemp.addAll(calendarAppointments);
      }
      
      allAppointments.assignAll(allAppointmentsTemp);
    } catch (e) {
      _handleError('Failed to load all appointments', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectCalendar(String calendarId) async {
    try {
      selectedCalendarId.value = calendarId;
      await loadAppointments(calendarId, _formatDate(selectedDay.value));
    } catch (e) {
      _handleError('Failed to select calendar', e);
    }
  }
  
  Future<void> updateSelectedDay(DateTime newDay) async {
    selectedDay.value = newDay;
    if (selectedCalendarId.isNotEmpty) {
      await loadAppointments(selectedCalendarId.value, _formatDate(newDay));
    }
  }

  Future<void> loadAppointments(String calendarId, String date) async {
    try {
      isLoading.value = true;
      final result = await calendarService.getAppointmentsByDate(calendarId, date);
      appointments.assignAll(result);
    } catch (e) {
      _handleError('Failed to load appointments', e);
      appointments.clear();
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> createCalendar(String name, String userId, String color) async {
    try {
      isLoading.value = true;
      final newCalendar = await calendarService.createCalendar(name, userId, color);
      calendars.add(newCalendar);
      await selectCalendar(newCalendar.id);
      await fetchAllAppointments(userId);
      Get.snackbar('Success', 'Calendar created', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      _handleError('Failed to create calendar', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editCalendar(String calendarId, Map<String, dynamic> calendarData) async {
    try {
      isLoading.value = true;
      await calendarService.editCalendar(calendarId, calendarData);
      
      // Update local calendar data
      final index = calendars.indexWhere((cal) => cal.id == calendarId);
      if (index != -1) {
        final updatedCalendar = calendars[index].copyWith(
          name: calendarData['calendarName'] ?? calendars[index].name,
        );
        calendars[index] = updatedCalendar;
      }
      
      Get.snackbar('Success', 'Calendar updated', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      _handleError('Failed to update calendar', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> softDeleteCalendar(String calendarId) async {
    try {
      isLoading.value = true;
      await calendarService.softDeleteCalendar(calendarId);
      
      // Update local data
      calendars.removeWhere((calendar) => calendar.id == calendarId);
      
      // Handle selected calendar if needed
      _handleCalendarDeletion(calendarId);
      
      Get.snackbar('Success', 'Calendar deleted', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      _handleError('Failed to delete calendar', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> hardDeleteCalendar(String calendarId) async {
    try {
      isLoading.value = true;
      await calendarService.hardDeleteCalendar(calendarId);
      
      // Update local data
      calendars.removeWhere((calendar) => calendar.id == calendarId);
      
      // Handle selected calendar if needed
      _handleCalendarDeletion(calendarId);
      
      Get.snackbar('Success', 'Calendar permanently deleted', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      _handleError('Failed to permanently delete calendar', e);
    } finally {
      isLoading.value = false;
    }
  }

  void _handleCalendarDeletion(String calendarId) {
    if (selectedCalendarId.value == calendarId) {
      if (calendars.isNotEmpty) {
        selectCalendar(calendars.first.id);
      } else {
        selectedCalendarId.value = '';
        appointments.clear();
      }
    }
  }

  Future<void> restoreCalendar(String calendarId) async {
    try {
      isLoading.value = true;
      await calendarService.restoreCalendar(calendarId);
      
      // Reload calendars to include the restored one
      await fetchCalendars(userId.value);
      
      Get.snackbar('Success', 'Calendar restored', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      _handleError('Failed to restore calendar', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAppointment(String calendarId, Map<String, dynamic> appointmentData) async {
    try {
      isLoading.value = true;
      
      // Ensure required fields have default values if not provided
      if (!appointmentData.containsKey('serviceType')) {
        appointmentData['serviceType'] = AppointmentServiceType.personal.toString().split('.').last.toLowerCase();
      }
      
      if (!appointmentData.containsKey('appointmentState')) {
        appointmentData['appointmentState'] = AppointmentState.requested.toString().split('.').last.toLowerCase();
      }
      
      final newAppointment = await calendarService.addAppointment(calendarId, appointmentData);
      
      // Update local data
      appointments.add(newAppointment);
      allAppointments.add(newAppointment);
      
      Get.snackbar('Success', 'Appointment added', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      _handleError('Failed to add appointment', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editAppointment(String calendarId, String appointmentId, Map<String, dynamic> appointmentData) async {
    try {
      isLoading.value = true;
      
      // This should call the service method when implemented
      //await calendarService.editAppointment(calendarId, appointmentId, appointmentData);
      
      // Refresh data
      await loadAppointments(calendarId, _formatDate(selectedDay.value));
      await fetchAllAppointments(userId.value);
      
      Get.snackbar('Success', 'Appointment updated', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      _handleError('Failed to update appointment', e);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> deleteAppointment(String calendarId, String appointmentId) async {
    try {
      isLoading.value = true;
      
      // This should call the service method when implemented
      //await calendarService.deleteAppointment(calendarId, appointmentId);
      
      // Update local data
      appointments.removeWhere((a) => a.id == appointmentId);
      allAppointments.removeWhere((a) => a.id == appointmentId);
      
      Get.snackbar('Success', 'Appointment deleted', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      _handleError('Failed to delete appointment', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeAppointmentState(String calendarId, String appointmentId, AppointmentState newState) async {
    try {
      isLoading.value = true;
      
      // This should call the service method when implemented
      //await calendarService.changeAppointmentState(calendarId, appointmentId, newState);
      
      // Refresh data
      await loadAppointments(calendarId, _formatDate(selectedDay.value));
      await fetchAllAppointments(userId.value);
      
      Get.snackbar('Success', 'Appointment state updated', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      _handleError('Failed to update appointment state', e);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<List<List<String>>> getCommonSlotsTwoUsers(
      String user1Id, String user2Id, String startDate, String endDate) async {
    try {
      isLoading.value = true;
      return await calendarService.getCommonSlotsTwoUsers(
        user1Id, user2Id, startDate, endDate);
    } catch (e) {
      _handleError('Failed to get common slots', e);
      return [];
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<List<List<String>>> getCommonSlotsMultipleUsers(
      List<String> userIds, String startDate, String endDate) async {
    try {
      isLoading.value = true;
      return await calendarService.getCommonSlotsMultipleUsers(
        userIds, startDate, endDate);
    } catch (e) {
      _handleError('Failed to get common slots for multiple users', e);
      return [];
    } finally {
      isLoading.value = false;
    }
  }
   final Rxn<Map<String, double>> coordinates = Rxn<Map<String, double>>();
   final RxList<Map<String, dynamic>> locationSuggestions = <Map<String, dynamic>>[].obs;
  
  Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=1',
    );

    final response = await http.get(url, headers: {
      'User-Agent': 'YourAppName (contact@example.com)',
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final lat = double.tryParse(data[0]['lat']);
        final lon = double.tryParse(data[0]['lon']);
        if (lat != null && lon != null) {
          return {'lat': lat, 'lng': lon};
        }
      }
    }
    return null;
  }
  Future<void> searchLocationSuggestions(String query) async {
    if (query.isEmpty) return;
    
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&limit=5',
    );

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'YourAppName (contact@example.com)',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        locationSuggestions.assignAll(data.map((item) => {
          'display_name': item['display_name'],
          'lat': double.tryParse(item['lat']),
          'lon': double.tryParse(item['lon']),
        }).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch locations');
    }
  }

  void clearLocationSuggestions() {
    locationSuggestions.clear();
  }
}