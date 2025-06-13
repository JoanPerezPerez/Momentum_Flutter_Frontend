import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/widgets/momentum_buttom_nav_bar.dart';
import 'package:momentum/widgets/profile_title.dart';
import 'package:momentum/widgets/profile_card.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const ProfileTitle(),
              const SizedBox(height: 20),
              Center(child: ProfileCard()),
              const SizedBox(height: 40), // Per respirar a baix
            ],
          ),
        ),
      ),
      bottomNavigationBar: MomentumBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}