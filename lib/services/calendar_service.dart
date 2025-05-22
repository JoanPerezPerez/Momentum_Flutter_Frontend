import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:momentum/models/calendar_model.dart';
import 'package:momentum/models/appointment_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:momentum/services/api_service.dart';

class CalendarService extends GetxService {
  final String baseUrl = 'https://ea5-api.upc.edu/calendars';
  //final String baseUrl = 'http://localhost:8080/calendars';
  static Dio get dio => ApiService.dio;

  // Obtener los calendarios de un usuario
  Future<List<CalendarModel>> getUserCalendars(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Accede al campo correcto que contiene la lista
      final calendarsJson = data['calendars'];

      if (calendarsJson is List) {
        return calendarsJson
            .map((e) => CalendarModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Se esperaba una lista en "calendars", pero se recibió: ${calendarsJson.runtimeType}',
        );
      }
    } else {
      throw Exception('Error al obtener calendarios: ${response.statusCode}');
    }
  }

  // Crear un nuevo calendario
  Future<CalendarModel> createCalendar(String name, String userId, String color) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      body: jsonEncode({
        'owner': userId,
        'calendarName': name,
        'defaultColour': color,
        'appointments': [],
        'invitees': [],
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('Response createCalendar: $data');
      return CalendarModel.fromJson(data);
    } else {
      throw Exception('Failed to create calendar: ${response.statusCode}');
    }
  }

  // Obtener citas por fecha específica
  Future<List<AppointmentModel>> getAppointmentsByDate(
    String calendarId,
    String date,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$calendarId/appointments/$date'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['appointments'] as List)
          .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error al obtener citas: ${response.statusCode}');
    }
  }

  // Obtener todas las citas de un calendario
  Future<List<AppointmentModel>> getAllAppointments(String calendarId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$calendarId/appointments/'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['appointments'] as List)
          .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Error al obtener todas las citas: ${response.statusCode}',
      );
    }
  }

  // Obtener citas entre dos fechas
  Future<List<AppointmentModel>> getAppointmentsBetweenDates(
    String calendarId,
    String startDate,
    String endDate,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$calendarId/appointments/$startDate/$endDate'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['appointments'] as List)
          .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Error al obtener citas entre fechas: ${response.statusCode}',
      );
    }
  }

  // Añadir una cita al calendario
  Future<AppointmentModel> addAppointment(
    String calendarId,
    Map<String, dynamic> appointmentData,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$calendarId/appointments'),
      body: jsonEncode(appointmentData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return AppointmentModel.fromJson(data);
    } else {
      throw Exception('Failed to add appointment: ${response.statusCode}');
    }
  }

  // Obtener slots comunes entre dos usuarios
  Future<List<List<String>>> getCommonSlotsTwoUsers(
    String user1Id,
    String user2Id,
    String date1,
    String date2,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/common-slots/two-users'),
      body: jsonEncode({
        'user1Id': user1Id,
        'user2Id': user2Id,
        'date1': date1,
        'date2': date2,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['commonSlots'] as List)
          .map((slot) => List<String>.from(slot))
          .toList();
    } else {
      throw Exception('Error al obtener slots comunes: ${response.statusCode}');
    }
  }

  // Obtener slots comunes entre múltiples usuarios
  Future<List<List<String>>> getCommonSlotsMultipleUsers(
    List<String> userIds,
    String date1,
    String date2,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/common-slots/multiple-users'),
      body: jsonEncode({'userIds': userIds, 'date1': date1, 'date2': date2}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return (data['commonSlots'] as List)
          .map((slot) => List<String>.from(slot))
          .toList();
    } else {
      throw Exception(
        'Error al obtener slots comunes múltiples: ${response.statusCode}',
      );
    }
  }

  // Soft delete de un calendario
  Future<void> softDeleteCalendar(String calendarId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$calendarId/soft-delete'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al eliminar calendario (soft): ${response.statusCode}',
      );
    }
  }

  // Hard delete de un calendario
  Future<void> hardDeleteCalendar(String calendarId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$calendarId'));

    if (response.statusCode != 200) {
      throw Exception(
        'Error al eliminar calendario permanentemente: ${response.statusCode}',
      );
    }
  }

  // Restaurar un calendario eliminado (soft)
  Future<void> restoreCalendar(String calendarId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$calendarId/restore'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al restaurar calendario: ${response.statusCode}');
    }
  }

  // Editar un calendario
  Future<void> editCalendar(
    String calendarId,
    Map<String, dynamic> calendarData,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$calendarId'),
      body: jsonEncode(calendarData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al editar calendario: ${response.statusCode}');
    }
  }
}
