import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:momentum/bindings/auth_binding.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/controllers/cataleg_controller.dart';
import 'package:momentum/services/api_service.dart';
import 'package:momentum/screens/login_screen.dart';
import 'package:momentum/screens/register_screen.dart';
import 'dart:convert';
import 'package:momentum/controllers/map_controller.dart';
import 'package:momentum/services/api_service.dart';
import 'package:momentum/routes/app_pages.dart';
import 'package:momentum/routes/app_routes.dart';
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  Get.put(AuthController());
  Get.put(MapController());
  Get.put(CatalegController());
  runApp(MyApp());
}
*/
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  runApp(GetMaterialApp(
    initialRoute: AppRoutes.login,
    getPages: AppPages.routes,
    debugShowCheckedModeBanner: false,
  ));
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: AuthBinding(),
      home: ButtonTextChange(),
    );
  }
}
