import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:momentum/services/api_service.dart';
import 'package:path_provider/path_provider.dart';

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
      body: Center(child: Text('Welcome to the Third Screen')),
    );
  }
}
