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
