import 'package:get/get.dart';
import 'package:momentum/main.dart';
import 'package:momentum/screens/home_screen.dart';
import 'package:momentum/screens/login_screen.dart';
import 'package:momentum/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var name = ''.obs;
  var age = 0.obs;
  var isLoading = false.obs;

  Future<void> login() async {
    isLoading.value = true;
    try {
      final response = await ApiService.login(email.value, password.value);
      final token = response["accessToken"];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_token", token);
      /*
      Per agafar despres el access_token:
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString("access_token");
*/
      Get.snackbar("Success", "Login successful!");
      Get.offAll(() => ThirdScreen()); // Navigate to ThirdScreen
    } catch (e) {
      Get.snackbar("Error", "Login failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
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
      Get.offAll(() => ButtonTextChange()); // Navigate to Login Screen
    } catch (e) {
      Get.snackbar(
        "Error",
        "Registration failed: ${e.toString()}, try with a diferent name or email, theese values are already in use.",
      );
    } finally {
      isLoading.value = false;
    }
  }
}
