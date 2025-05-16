import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:momentum/routes/app_routes.dart';

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
              },
              child: const Text('Anar al Catàleg'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(AppRoutes.chatlist);
              },
              child: const Text('Anar al Xat'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(AppRoutes.map);
              },
              child: const Text('Anar al mapa'),
            ),
          ],
        ),
      ),
    );
  }
}
