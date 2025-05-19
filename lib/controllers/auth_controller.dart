import 'package:get/get.dart';
import 'package:momentum/controllers/socket_controller.dart';
import 'package:momentum/screens/home_screen.dart';
import 'package:momentum/screens/login_screen.dart';
import 'package:momentum/services/api_service.dart';
import 'package:momentum/models/user_model.dart';
import 'package:momentum/services/socket_service.dart';

class AuthController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var name = ''.obs;
  var age = 0.obs;
  var isLoading = false.obs;
  Rx<Usuari> currentUser =
      Usuari(id: '', name: '', mail: '', age: 0, favoriteLocations: []).obs;

  Future<void> login() async {
    isLoading.value = true;
    try {
      var reponse = await ApiService.login(email.value, password.value);
      this.currentUser.value = Usuari.fromJson(reponse);
      socketLogin();
      Get.offAll(() => HomeScreen());
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
    print("sending test");
    socketController.sendMessage('test', "test1");
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
    final accessToken = await ApiService.secureStorage.read(
      key: 'access_token',
    );
    /*
    S'ha de fer el següent:
    1. Comprovar si l'usuari té un access token i refresh token.
      1.1 Si té un access token i un refresh, fer una petició a l'API per comprovar si són vàlids.
      1.2 Si és vàlid, no cal login.
      1.3 Fer una petició per obtenir l'usuari a partir de l'id que treu del access token.
    2. Si té refresh token i no acces token, fer una petició a l'API per obtenir un access token.
      2.1 Si és vàlid, no cal login.
      2.2 Si no és vàlid, fer login.
      2.3 Fer una petició per obtenir l'usuari a partir de l'id que treu del access token.
    3. Si no té access token ni refresh token, fer login.
    */
  }
}
