import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/controllers/socket_controller.dart';
import 'package:momentum/controllers/xat_controller.dart';
import 'package:momentum/services/api_service.dart';
import 'package:momentum/services/socket_service.dart';
import 'package:momentum/routes/app_pages.dart';
import 'package:momentum/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  Get.put(AuthController());
  Get.put(XatController());
  /*   Get.lazyPut<XatController>(() => XatController());
  Get.lazyPut<SocketController>(() => SocketController()); */
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: const Locale('es', 'ES'),
      initialRoute: AppRoutes.login,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
