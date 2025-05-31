import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/admin_controller.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/controllers/xat_controller.dart';
import 'package:momentum/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:momentum/routes/app_pages.dart';
import 'package:momentum/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await ApiService.init();
  Get.put(AuthController());
  Get.put(XatController());
  Get.put(AdminController());
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
