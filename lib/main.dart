import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/admin_controller.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/controllers/xat_controller.dart';
import 'package:momentum/controllers/amistats_controller.dart';
import 'package:momentum/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:momentum/routes/app_pages.dart';
import 'package:momentum/routes/app_routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';

//Funció que es crida si arriba una notificació amb l'app tancada
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('🔕 Notificació rebuda amb l’app tancada: ${message.notification?.title}');
}
///Aquesta és la teva VAPID key pública (no confidencial)
const String vapidKey = 'BLgA_vkn-49Av-FvlygMOvgFcpn7O73yFhoVtiHYUy7q9TAmNMOBAFvSnLQw1sx3wZ4Mt7bp3Xwc9CUmkQjtfS4';

///Permisos i inicialització per web
Future<void> setupFirebaseMessagingWeb() async {
  try {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
    print('📢 Permisos concedits: ${settings.authorizationStatus}');

    final token = await FirebaseMessaging.instance.getToken(vapidKey: vapidKey);
    print('📲 Token de notificacions Web: $token');
  } catch (e) {
    print('❌ Error configurant FCM Web: $e');
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb) {
    await setupFirebaseMessagingWeb(); 
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await ApiService.init();
  Get.put(AuthController());
  Get.put(XatController());
  Get.put(AdminController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Escolta notificacions mentre l’app està oberta
   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final title = message.notification!.title ?? '';
        final body = message.notification!.body ?? '';

        print('🔔 Notificació rebuda en primer pla: $title');
        // Comprova si el controlador existeix i executa la funció
        if (Get.isRegistered<FriendController>()) {
          final controller = Get.find<FriendController>();
          controller.loadUserIdAndRequestsAndFriends();
        }
        // Mostra la notificació a la UI
        Get.snackbar(
          title,
          body,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.blue.shade50,
          colorText: Colors.black87,
          borderRadius: 12,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          icon: const Icon(Icons.check_circle_outline, color: Colors.blueAccent),
          padding: const EdgeInsets.all(16),
          snackStyle: SnackStyle.FLOATING,
        );
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
