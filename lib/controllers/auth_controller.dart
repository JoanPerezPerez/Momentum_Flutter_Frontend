import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/socket_controller.dart';
import 'package:momentum/routes/app_routes.dart';
import 'package:momentum/screens/login_screen.dart';
import 'package:momentum/screens/profile_screen.dart';
import 'package:momentum/services/api_service.dart';
import 'package:momentum/models/user_model.dart';
import 'package:momentum/models/worker_model.dart' as my_models;
import 'package:momentum/services/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  var selectedRole = 'user'.obs;
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var name = ''.obs;
  var age = 0.obs;
  var isLoading = false.obs;
  var showPasswordCard = false.obs;
  var isAdmin = false.obs;
  Rx<Usuari> currentUser =
      Usuari(id: '', name: '', mail: '', age: 0, favoriteLocations: []).obs;
  Rx<my_models.Worker> currentWorker =
      my_models.Worker(
        id: '',
        name: '',
        mail: '',
        age: 0,
        role: '',
        location: [],
        businessAdministrated: '',
      ).obs;

  Future<void> login() async {
    isLoading.value = true;
    try {
      if (selectedRole == "user") {
        var reponse = await ApiService.userLogin(email.value, password.value);
        currentUser.value = Usuari.fromJson(reponse);
        socketLogin();
        Get.offAll(() => ProfileScreen());
      } else if (selectedRole == "worker") {
        var reponse = await ApiService.workerLogin(email.value, password.value);
        currentWorker.value = my_models.Worker.fromJson(reponse);
        socketLogin();
        Get.offAll(() => ProfileScreen());
      }
    } catch (e) {
      Get.snackbar("Error", "Login failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  void socketLogin() async {
    final socketService = await SocketService.create();
    Get.put(socketService);
    Get.put(SocketController());
    SocketController socketController = Get.find<SocketController>();
    socketController.sendMessage('user_login', currentUser.value.name);
  }

  void socketLogout() async {
    SocketService socketService = Get.find<SocketService>();
    socketService.disconnect();
  }

  Future<void> register() async {
    if (password.value.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters");
      return;
    }
    if (password.value != confirmPassword.value) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }
    isLoading.value = true;
    try {
      await ApiService.register(
        name.value,
        email.value,
        password.value,
        age.value,
      );
      Get.snackbar(
        "Success",
        "Check your email for verification link! ATTENTION!! It might be in the spam folder.",
      );
      Get.offAll(() => LoginScreen());
    } catch (e) {
      Get.snackbar(
        "Error",
        "Registration failed: ${e.toString()}, try with a diferent name or email, theese values are already in use.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkIfLoggedIn() async {
    try {
      var answer = await ApiService.sendHola();
      if (answer["type"] == "user") {
        selectedRole.value = "user";
        currentUser.value = Usuari.fromJson(answer["data"]);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', currentUser.value.id as String);
        Get.offAll(() => ProfileScreen());
      } else if (answer["type"] == "worker") {
        selectedRole.value = "worker";
        currentWorker.value = my_models.Worker.fromJson(answer["data"]);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', currentWorker.value.id as String);
        Get.offAll(() => ProfileScreen());
      }
    } catch (e) {
      //Get.offAll(() => LoginScreen());
    }
  }

  Future<void> logout() async {
    try {
      final k = await ApiService.logout();
      if (k == 0) {
        await ApiService.secureStorage.delete(key: 'access_token');
        await ApiService.secureStorage.delete(key: 'refresh_token');
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('userId');
        await prefs.remove('workerId');

        socketLogout();
        currentUser.value = Usuari(
          id: '',
          name: '',
          mail: '',
          age: 0,
          favoriteLocations: [],
        );
        currentWorker.value = my_models.Worker(
          id: '',
          name: '',
          mail: '',
          age: 0,
          role: '',
          location: [],
          businessAdministrated: '',
        );
        Get.offAll(() => LoginScreen());
      } else {
        Get.snackbar("Error", "Logout failed");
      }
    } catch (e) {
      Get.snackbar("Error", "Logout failed: ${e.toString()}");
    }
  }

  void togglePasswordCard() {
    showPasswordCard.value = !showPasswordCard.value;
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String repeatPassword,
  ) async {
    try {
      await ApiService.changePassword(
        currentUser.value.id as String,
        currentPassword,
        newPassword,
      );
      Get.snackbar("Success", "Password changed successfully");
      showPasswordCard.value = false;
    } catch (e) {
      Get.snackbar("Error", "Failed to change password: ${e.toString()}");
    }
  }

  InputDecoration inputDecoration(String labelText, {IconData? icon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white),
      prefixIcon: icon != null ? Icon(icon, color: Colors.white) : null,
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white70),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white, width: 2.0),
        borderRadius: BorderRadius.circular(12),
      ),
      floatingLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Future<void> registerBusiness(
    String name,
    String businessName,
    int age,
    String mail,
    String password,
  ) async {
    final worker = await ApiService.registerBusiness(
      name,
      businessName,
      age,
      mail,
      password,
    );
    currentWorker.value = worker;
    isAdmin.value = true;
    selectedRole.value = "worker";
    Get.toNamed(AppRoutes.profile);
  }
}
