import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:momentum/services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:momentum/screens/catalog_screen.dart';

class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  @override
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CatalogScreen()),
                );
              },
              child: const Text('Anar al Catàleg'),
            ),
          ],
        ),
      ),
    );
  }
}