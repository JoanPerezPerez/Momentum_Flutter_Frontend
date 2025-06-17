import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/socket_controller.dart';
import 'package:momentum/models/location_model.dart';
import 'package:momentum/screens/calendar/calendar_homescreen.dart';
import 'package:momentum/routes/app_routes.dart';
import 'package:momentum/screens/login_screen.dart';
import 'package:momentum/screens/profile_screen.dart';
import 'package:momentum/services/api_service.dart';
import 'package:momentum/models/user_model.dart';
import 'package:momentum/models/worker_model.dart' as my_models;
import 'package:momentum/services/cataleg_service.dart';
import 'package:momentum/services/socket_service.dart';
import 'package:momentum/widgets/card/location_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  var selectedRole = 'user'.obs;
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var currentPassword = ''.obs;
  var name = ''.obs;
  var businessName = ''.obs; 
  var age = 0.obs;
  var isLoading = false.obs;
  var showPasswordCard = false.obs;
  var isAdmin = false.obs;
  var hasMinLength = false.obs;        
  var hasTwoUppercase = false.obs;     
  var hasSpecialChar = false.obs; 
  var closeMedicalLocations = <ILocation>[].obs;
  var userLat = RxnDouble();
  var userLng = RxnDouble();
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

  final RxBool showUpdateWorkerCard = false.obs;

  void registerClean() {
    name.value = '';
    businessName.value = '';
    age.value = 0;
    email.value = '';
    password.value = '';
    confirmPassword.value = '';
    hasMinLength.value = false;
    hasTwoUppercase.value = false;
    hasSpecialChar.value = false;
  }

  void toggleUpdateWorkerCard() {
    showUpdateWorkerCard.value = !showUpdateWorkerCard.value;
  }

  Future<void> login() async {
    isLoading.value = true;
    try {
      if (selectedRole.value == "user") {
        var reponse = await ApiService.userLogin(email.value, password.value);
        currentUser.value = Usuari.fromJson(reponse);
        socketLogin();
        Get.offAll(() => ProfileScreen());
      } else if (selectedRole.value == "worker") {
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
    if (selectedRole.value == "user") {
      socketController.sendMessage('user_login', currentUser.value.id);
    } else if (selectedRole.value == "worker") {
      socketController.sendMessage('user_login', currentWorker.value.id);
      try {
        final bussinessId = await ApiService.getBusinessIdFromLocationId(
          currentWorker.value.location[0],
        );
        var rooms = [];
        for (var location in currentWorker.value.location) {
          rooms.add("location/$location");
        }
        rooms.add("business/$bussinessId");
        socketController.sendMessage('join_rooms', {
          'userId': currentWorker.value.id,
          'rooms': rooms,
        });
      } catch (e) {
        Get.snackbar(
          "Error",
          "Joining rooms failed: ${e.toString()}, try again later.",
        );
      }
    }
  }

  void socketLogout() async {
    SocketService socketService = Get.find<SocketService>();
    socketService.disconnect();
  }

  String? validatePassword(String password) {
    final minLength = password.length >= 8;
    final twoUppercase = RegExp(r'(.*[A-Z].*){2,}').hasMatch(password);
    final oneSpecialChar = RegExp(r'[!@#\$&*~%^()_\-+=\[\]{};:"\\|,.<>/?]').hasMatch(password);

    if (!minLength) return 'La contrasenya ha de tenir almenys 8 caràcters';
    if (!twoUppercase) return 'La contrasenya ha de contenir almenys 2 lletres majúscules';
    if (!oneSpecialChar) return 'La contrasenya ha de contenir almenys 1 caràcter especial';

    return null;
  }

  void updatePassword(String value) {
    password.value = value;
    hasMinLength.value = value.length >= 8;
    hasTwoUppercase.value = RegExp(r'(.*[A-Z].*){2,}').hasMatch(value);
    hasSpecialChar.value = RegExp(r'[!@#\$&*~%^()_\-+=\[\]{};:"\\|,.<>/?]').hasMatch(value);
  }

  Future<void> register() async {
    final passwordError = validatePassword(password.value);
    if (passwordError != null) {                                   
      Get.snackbar("Error", passwordError,                          
          backgroundColor: Colors.red.shade100,                     
          colorText: Colors.red.shade800);                          
      return;                                                       
    }      
    if (password.value != confirmPassword.value) {
      Get.snackbar("Error", "Passwords do not match",                          
          backgroundColor: Colors.red.shade100,                     
          colorText: Colors.red.shade800);   
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
      registerClean();
      Get.offAll(() => LoginScreen());
    } catch (e) {
      Get.snackbar(
        "Error",
        "Registration failed: ${e.toString()}, try with a diferent name or email, theese values are already in use.",
        backgroundColor: Colors.red.shade100,                     
        colorText: Colors.red.shade800, 
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
        socketLogin();
        Get.offAll(() => ProfileScreen());
      } else if (answer["type"] == "worker") {
        selectedRole.value = "worker";
        currentWorker.value = my_models.Worker.fromJson(answer["data"]);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', currentWorker.value.id as String);
        socketLogin();
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

  /*
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
  }*/

  Future<void> changePassword() async {
  final passwordError = validatePassword(password.value);
  if (passwordError != null) {
    Get.snackbar("Error", passwordError,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800);
    return;
  }

  if (password.value != confirmPassword.value) {
    Get.snackbar("Error", "Les contrasenyes no coincideixen",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800);
    return;
  }

  try {
    var result = await ApiService.changePassword(
      currentUser.value.id as String,
      currentPassword.value,
      password.value,
    );
    if (result == 0){
       Get.snackbar("Èxit", "Contrasenya canviada correctament");
    showPasswordCard.value = false;
    currentPassword.value = '';
    password.value = '';
    confirmPassword.value = '';
    hasMinLength.value = false;
    hasTwoUppercase.value = false;
    hasSpecialChar.value = false;
    }
    else {
      Get.snackbar("Error", "No s'ha pogut canviar la contrasenya, potser la contrasenya actual no és correcta.",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800);
    }
  } catch (e) {
    final errorMessage = e.toString();
    Get.snackbar("Error", errorMessage,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800);
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

  /*
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
  */
  Future<void> registerBusiness() async {
    final passwordError = validatePassword(password.value);
    if (passwordError != null) {
      Get.snackbar(
        "Error",
        passwordError,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (password.value != confirmPassword.value) {
      Get.snackbar(
        "Error",
        "Les contrasenyes no coincideixen",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    isLoading.value = true;
    try {
      await ApiService.registerBusiness(name.value,businessName.value,age.value,email.value,password.value);
      //currentWorker.value = worker;
      //isAdmin.value = true;
      //selectedRole.value = "worker";
      registerClean();
      Get.snackbar("Èxit", "Negoci registrat correctament!");
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        "Error",
        "No s'ha pogut registrar el negoci: ${e.toString()}.\nComprova que el correu no estigui ja en ús.",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCloseMedicalLocations() async {
    isLoading.value = true;

    try {
      if (userLat.value == null || userLng.value == null) {
        Get.snackbar("Error", "User location not set.");
        return;
      }

      final response = await CatalegService.getCloseMedicalLocations( userLat.value!, userLng.value!);

      if (response.isNotEmpty) {
        closeMedicalLocations.value = response;
        userLat.value = null;
        userLng.value = null;
      } else {
        Get.snackbar("Error", "Medical locations not correctly charged.");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
