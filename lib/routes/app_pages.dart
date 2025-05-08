import 'package:get/get.dart';
import 'package:momentum/bindings/cataleg_binding.dart';
import 'package:momentum/bindings/map_binding.dart';
import 'package:momentum/screens/catalog_screen.dart';
import 'package:momentum/screens/login_screen.dart';
import 'package:momentum/screens/map_screen.dart';
import 'package:momentum/screens/register_screen.dart';
import 'package:momentum/screens/home_screen.dart';
import 'package:momentum/bindings/auth_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => ButtonTextChange(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => SecondScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => ThirdScreen(),
    ),
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
  ];
}
