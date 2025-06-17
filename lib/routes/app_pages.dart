import 'package:get/get.dart';
import 'package:momentum/bindings/calendar_binding.dart';
import 'package:momentum/bindings/cataleg_binding.dart';
import 'package:momentum/bindings/map_binding.dart';
import 'package:momentum/bindings/recordatoris_binding.dart'
    show RecordatorisBinding;
import 'package:momentum/screens/business_register.dart';
import 'package:momentum/screens/amistats_screen.dart';
import 'package:momentum/screens/calendar/calendar_homescreen.dart';
import 'package:momentum/bindings/userList_binding.dart';
import 'package:momentum/bindings/xat_binding.dart';
import 'package:momentum/bindings/notifications_binding.dart';
import 'package:momentum/screens/Xat/user_list.dart';
import 'package:momentum/screens/Xat/xat_screen.dart';
import 'package:momentum/screens/catalog_screen.dart';
import 'package:momentum/screens/location_register.dart';
import 'package:momentum/screens/login_screen.dart';
import 'package:momentum/screens/map_screen.dart';
import 'package:momentum/screens/recordatoris_screen.dart';
import 'package:momentum/screens/medical_screen.dart';
import 'package:momentum/screens/register_screen.dart';
import 'package:momentum/screens/home_screen.dart';
import 'package:momentum/screens/profile_screen.dart';
import 'package:momentum/bindings/auth_binding.dart';
import 'package:momentum/screens/req_appointments/request_appointments_screen.dart';
import 'package:momentum/screens/optimization_screen.dart';
import 'package:momentum/bindings/optimization_binding.dart';
import 'package:momentum/screens/worker_register.dart';

import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(name: AppRoutes.register, page: () => RegisterScreen()),
    GetPage(name: AppRoutes.home, page: () => HomeScreen()),
    GetPage(name: AppRoutes.profile, page: () => ProfileScreen()),
    GetPage(
      name: AppRoutes.cataleg,
      page: () => CatalogScreen(),
      binding: CatalegBinding(),
    ),
    GetPage(
      name: AppRoutes.map,
      page: () => MapSample(),
      binding: MapBinding(),
    ),
    GetPage(
      name: AppRoutes.calendar,
      page: () => const CalendarScreen(),
      binding: CalendarBinding(),
    ),
    GetPage(
      name: AppRoutes.chatlist,
      page: () => UserListScreen(),
      binding: UserlistBinding(),
    ),
    GetPage(
      name: AppRoutes.xat,
      page: () => XatScreen(),
      binding: XatBinding(),
    ),
    GetPage(
      name: AppRoutes.reqAppointments,
      page: () =>ReqAppointmentscreen(),
      binding: CalendarBinding(),
    ),
    GetPage(
      name: AppRoutes.optimization,
      page: () => OptimizationScreen(),
      binding: OptimizationBinding(),
    ),
    GetPage(
      name: AppRoutes.businessRegister,
      page: () => BusinessRegisterScreen(),
    ),
    GetPage(
      name: AppRoutes.locationRegister,
      page: () => RegisterLocationScreen(),
    ),
    GetPage(name: AppRoutes.workerRegister, page: () => WorkerRegister()),
    GetPage(
      name: AppRoutes.friends,
      page: () => AmistatsScreen(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: AppRoutes.recordatoris,
      page: () => RecordatorisScreen(),
      binding: RecordatorisBinding(),
    ),
    GetPage(
      name: AppRoutes.medical,
      page: () => MedicalScreen(),
    ),
  ];
}
