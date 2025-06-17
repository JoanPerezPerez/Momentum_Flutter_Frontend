import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/admin_controller.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/controllers/xat_controller.dart';
import 'package:momentum/controllers/navigator_controller.dart';
import 'package:momentum/controllers/amistats_controller.dart';
import 'package:momentum/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:momentum/routes/app_pages.dart';
import 'package:momentum/routes/app_routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

const String vapidKey =
    'BLgA_vkn-49Av-FvlygMOvgFcpn7O73yFhoVtiHYUy7q9TAmNMOBAFvSnLQw1sx3wZ4Mt7bp3Xwc9CUmkQjtfS4';

Future<void> setupFirebaseMessagingWeb() async {
  try {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission();
    print('Permisos concedits: ${settings.authorizationStatus}');

    final token = await FirebaseMessaging.instance.getToken(vapidKey: vapidKey);
    print('Token de notificacions Web: $token');
  } catch (e) {
    print('Error configurant FCM Web: $e');
  }
}

late final AppLinks _appLinks;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kIsWeb) {
    await setupFirebaseMessagingWeb();
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await ApiService.init();

  // INICIO: Listener de enlaces profuns (Google Login callback)
  _appLinks = AppLinks();
  _appLinks.uriLinkStream.listen((Uri? uri) async {
    if (uri == null) return;

    if (uri.scheme == 'momentum' && uri.host == 'auth') {
      final token = uri.queryParameters['token'];
      final refreshToken = uri.queryParameters['refreshToken'];
      final userId = uri.queryParameters['userId'];

      if (token != null) {
        await ApiService.secureStorage.write(key: 'access_token', value: token);
        if (refreshToken != null) {
          await ApiService.secureStorage.write(key: 'refresh_token', value: refreshToken);
        }
        if (userId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);
        }

        // Redirige al home (ajusta si usas otra ruta)
        Get.offAllNamed('/home');
      }
    }
  });
  // FIN

  Get.put(AuthController());
  Get.put(XatController());
  Get.put(AdminController());
  Get.put(NavigationController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final title = message.notification!.title ?? '';
        final body = message.notification!.body ?? '';
        if (Get.isRegistered<FriendController>()) {
          final controller = Get.find<FriendController>();
          controller.loadUserIdAndRequestsAndFriends();
        }
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

