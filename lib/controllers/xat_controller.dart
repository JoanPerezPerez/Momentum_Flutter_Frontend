import 'package:get/get.dart';
import 'package:momentum/main.dart';
import 'package:momentum/services/xat_service.dart';
import 'package:momentum/models/message_model.dart';

class XatController extends GetxController {
  var users = <List<String>>[].obs;
  var chatId = ''.obs;
  var isLoading = false.obs;
  var chatMessages = <ChatMessage>[].obs;
  var correctlySent = false.obs;
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

  Future<void> getChatId(String user1Id, String user2Id) async {
    isLoading.value = true;
    try {
      final response = await XatService.getChatId(user1Id, user2Id);
      chatId.value = response;
    } catch (e) {
      Get.snackbar("Error", "get chat id failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getChatMessages(String chatId) async {
    isLoading.value = true;
    try {
      final response = await XatService.getMessagesofChat(chatId);
      chatMessages.value = response;
    } catch (e) {
      Get.snackbar("Error", "get messages failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(
    String chatId,
    String userFrom,
    String message,
  ) async {
    isLoading.value = true;
    try {
      final response = await XatService.sendMessage(chatId, userFrom, message);
      if (response != 200) {
        Get.snackbar("Error", "Failed to send message");
      } else {
        correctlySent.value = true;
      }
    } catch (e) {
      Get.snackbar("Error", "send message failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}
