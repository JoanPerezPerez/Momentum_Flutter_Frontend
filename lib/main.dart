import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/controllers/xat_controller.dart';
import 'package:momentum/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:momentum/routes/app_pages.dart';
import 'package:momentum/routes/app_routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';


//Funció que es crida si arriba una notificació amb l'app tancada
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Notificació en segon pla: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await ApiService.init();
  Get.put(AuthController());
  Get.put(XatController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Escolta notificacions mentre l’app està oberta
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Notificació rebuda en primer pla: ${message.notification!.title}');
      }
    });
    return GetMaterialApp(
      locale: const Locale('es', 'ES'),
      initialRoute: AppRoutes.login,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
