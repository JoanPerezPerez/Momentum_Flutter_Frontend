// calendar_binding.dart
import 'package:get/get.dart';
import 'package:momentum/controllers/calendar_controller.dart';
import 'package:momentum/services/calendar_service.dart';

class CalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CalendarService>(() => CalendarService());
    Get.lazyPut<CalendarController>(() => CalendarController());
  }
}
