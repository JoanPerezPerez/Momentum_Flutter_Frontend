import 'package:get/get.dart';
import 'package:momentum/main.dart';
import 'package:momentum/services/xat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class XatController extends GetxController {
  var users = <List<String>>[].obs;
  var isLoading = false.obs;

  Future<void> getUserWithWhomUserChatted(String userId) async {
    isLoading.value = true;
    try {
      final response = await XatService.getPeopleWithWhomUserChatted(userId);
      users.value = response;
    } catch (e) {
      Get.snackbar("Error", "Login failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}
