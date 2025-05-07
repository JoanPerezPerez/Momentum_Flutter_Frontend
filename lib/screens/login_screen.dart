import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/main.dart';
import 'package:momentum/screens/register_screen.dart';

class ButtonTextChange extends StatefulWidget {
  @override
  _ButtonTextChangeState createState() => _ButtonTextChangeState();
}

class _ButtonTextChangeState extends State<ButtonTextChange> {
  final AuthController authController = Get.find();
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pantalla de Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              onChanged: (value) => authController.email.value = value,
              decoration: InputDecoration(
                labelText: "Enter your name or email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              onChanged: (value) => authController.password.value = value,
              decoration: InputDecoration(
                labelText: "Enter your password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Obx(
              () => ElevatedButton(
                onPressed:
                    authController.isLoading.value
                        ? null
                        : authController.login,
                child:
                    authController.isLoading.value
                        ? CircularProgressIndicator()
                        : Text("Login"),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.to(() => SecondScreen()),
              child: Text("Register"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => authController.loginWithGoogle(),
              child: Text("Login with Google"),
            ),
          ],
        ),
      ),
    );
  }
}
