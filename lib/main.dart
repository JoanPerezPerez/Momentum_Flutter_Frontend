import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/bindings/auth_binding.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/controllers/cataleg_controller.dart';
import 'package:momentum/controllers/socket_controller.dart';
import 'package:momentum/controllers/xat_controller.dart';
import 'package:momentum/screens/login_screen.dart';
import 'package:momentum/services/api_service.dart';
import 'package:momentum/services/socket_service.dart';
import 'package:momentum/controllers/map_controller.dart';
import 'package:momentum/routes/app_pages.dart';
import 'package:momentum/routes/app_routes.dart';

/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  await initializeDateFormatting('es_ES', null);
  Get.put(AuthController());
  Get.put(MapController());
  Get.put(CatalegController());
  runApp(MyApp());
}
*/
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  final socketService = await SocketService.create();
  Get.put(socketService);
  Get.put(AuthController());
  Get.put(MapController());
  Get.put(CatalegController());
  Get.put(XatController());
  Get.put(SocketController());
  runApp(
    GetMaterialApp(
      initialRoute: AppRoutes.login,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: const Locale('es', 'ES'),
      initialBinding: AuthBinding(),
      home: ButtonTextChange(),
    );
  }
}
