import 'package:flutter/material.dart';
import 'package:momentum/models/user_model.dart';

class UserTile extends StatelessWidget {
  final Usuari user;
  final VoidCallback onTap;

  const UserTile({required this.user, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(user.name), onTap: onTap);
  }
}
