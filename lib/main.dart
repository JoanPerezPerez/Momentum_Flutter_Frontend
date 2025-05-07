import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:momentum/bindings/auth_binding.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/services/api_service.dart';
import 'package:momentum/screens/login_screen.dart';
import 'package:momentum/screens/register_screen.dart';
import 'dart:convert';
import 'package:momentum/controllers/map_controller.dart';
import 'package:momentum/services/api_service.dart';
import 'package:momentum/services/calendar_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  await initializeDateFormatting('es_ES', null);
  Get.put(AuthController());
  Get.put(MapController());
  runApp(MyApp());
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
