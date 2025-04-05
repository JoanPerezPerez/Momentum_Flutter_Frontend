import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:momentum/bindings/auth_binding.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/screens/login_screen.dart';
import 'package:momentum/screens/register_screen.dart';
import 'dart:convert';

import 'package:momentum/services/api_service.dart';

void main() {
  Get.put(AuthController());
  runApp(MyApp());
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
