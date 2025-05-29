import 'package:get/get.dart';
import 'package:momentum/services/IA_service.dart';

class OptimizationController extends GetxController {
  var textToSend = '';
  var answerFromIA = ''.obs;
  var isLoading = false.obs;

  Future<void> sendTestMesage() async {
    isLoading.value = true;
    try {
      var reponse = await IaService.test(textToSend);
      answerFromIA.value = reponse;
    } catch (e) {
      Get.snackbar("Error", "Login failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessageToBackend() async {
    isLoading.value = true;
    try {
      var reponse = await IaService.sendOptimization(textToSend);
      if (reponse != null) {
        answerFromIA.value = reponse['answer'] ?? 'No answer received';
      } else {
        answerFromIA.value = 'No response from server';
      }
    } catch (e) {
      Get.snackbar("Error", "Login failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}
