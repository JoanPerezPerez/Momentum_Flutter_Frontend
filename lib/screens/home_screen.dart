import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/screens/calendar/calendar_homescreen.dart';
import 'package:momentum/controllers/xat_controller.dart';
import 'package:momentum/screens/Xat/user_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:momentum/screens/map_screen.dart';

class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {

  String? token;
  String? userId;
  int _selectedIndex = 0;


  @override
  void initState() {
    super.initState();


  // Método para cargar el token
  _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString("access_token");
      userId = prefs.getString("user_id");
    });
  }

  // Método para cambiar entre páginas
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

    Future.delayed(Duration.zero, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MapSample()),
      );

    });
  }

  // Método para obtener el widget correspondiente a cada opción de la navbar
  Widget _getBody() {
    switch (_selectedIndex) {
      case 0: // Calendar
        return CalendarScreen(userId: userId ?? '6809f8e2efaf3f5201dd25d6');
      case 1: // Chats
        return Center(child: Text("Chats"));
      case 2: // Account
        return Center(child: Text("Cuenta"));
      case 3: // Settings
        return Center(child: Text("Configuración"));
      default:
        return Center(child: Text("No disponible"));
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      //appBar: AppBar(title: Text('Home Screen')),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Account',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    ),
    );

    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
