import 'package:flutter/material.dart';
import 'package:momentum/widgets/momentum_buttom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  }

  _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString("access_token");
      userId = prefs.getString("user_id");
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MomentumBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:momentum/routes/app_routes.dart';
import 'package:momentum/services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:momentum/screens/catalog_screen.dart';

class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Third Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the Third Screen'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(AppRoutes.cataleg);
                /*
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CatalogScreen()),
                );
                */
              },
              child: const Text('Anar al Catàleg'),
            ),
          ],
        ),
      ),
    );
  }*/
