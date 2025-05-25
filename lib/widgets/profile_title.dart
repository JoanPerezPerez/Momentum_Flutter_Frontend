import 'package:flutter/material.dart';

class ProfileTitle extends StatelessWidget {
  const ProfileTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Perfil d\'usuari',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }
}
