/* import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/screens/login_screen.dart';

class ThirdScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: Center(child: Text("Welcome to the HOME PAGE!")),
    );
  }
}
 */
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:momentum/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  String? token;
  List<String> cookiesList = [];
  Dio dio = Dio(); // Dio instance for network requests

  @override
  void initState() {
    super.initState();
    _loadToken();
    _loadCookies();
  }

  // Mètode per carregar el token des de SharedPreferences
  _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString("access_token");
    });

    // Ara cridem a la funció per refrescar el token (independentment de si el token existeix)
    _refreshToken();
  }

  // Mètode per carregar les cookies
  _loadCookies() async {
    final directory = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage('${directory.path}/.cookies/'),
    );

    final uri = Uri.parse("http://localhost:8080"); // Modifica per la teva URL
    final cookies = await cookieJar.loadForRequest(uri);

    setState(() {
      cookiesList =
          cookies.map((cookie) => "${cookie.name} = ${cookie.value}").toList();
    });
  }

  // Mètode per refrescar el token
  _refreshToken() async {
    try {
      final response = await ApiService.refreshToken();
    } catch (e) {
      print("Error refreshing token: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Third Screen')),
      body: Center(
        child:
            token == null
                ? CircularProgressIndicator() // Mostra un indicador de càrrega mentre es carrega el token
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Access Token: $token"),
                    SizedBox(height: 20),
                    Text("Cookies:"),
                    ...cookiesList.isEmpty
                        ? [
                          Text("No cookies found"),
                        ] // Si no hi ha cookies, mostra aquest missatge
                        : cookiesList.map((cookie) => Text(cookie)).toList(),
                  ],
                ),
      ),
    );
  }
}
