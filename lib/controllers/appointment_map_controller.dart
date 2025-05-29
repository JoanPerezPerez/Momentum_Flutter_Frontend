import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:momentum/models/appointment_model.dart';
import 'package:momentum/models/location_model.dart';
import 'package:momentum/services/calendar_service.dart';
import 'package:momentum/services/mapa_service.dart';

class AppointmentMapController extends GetxController {
  var appointments = <AppointmentModel>[].obs;
  var locationsCache = <String, ILocation>{}.obs;
  final String calendarId = Get.arguments['calendarId'];

  Future<void> loadAppointmentsByDate(String calendarId, String date) async {
    final list = await CalendarService().getAppointmentsByDate(calendarId, date);
    list.sort((a, b) => a.inTime.compareTo(b.inTime));
    appointments.assignAll(list);

    for (var appt in appointments) {
      final locId = appt.locationId;
      if (locId != null && !locationsCache.containsKey(locId)) {
        final loc = await MapService.getLocationById(locId);
        locationsCache[locId] = loc;
      }
    }
  }
}