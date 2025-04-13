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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  // Mètode per carregar el token
  _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString("access_token");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: Center(
        child:
            token == null
                ? CircularProgressIndicator() // Mostra un indicador de càrrega mentre es carrega el token
                : Text(
                  "Access Token: $token",
                ), // Mostra el token quan estigui disponible
      ),
    );
  }
}
