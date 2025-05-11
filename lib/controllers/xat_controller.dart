import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:get/get.dart';
import 'package:momentum/models/user_model.dart';
import 'package:momentum/services/xat_service.dart';
import 'package:momentum/models/message_model.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class XatController extends GetxController {
  var users = <List<String>>[].obs;
  var chatId = ''.obs;
  var isLoading = false.obs;
  var chatMessages = <ChatMessage>[].obs;
  var correctlySent = false.obs;
  Rx<Usuari> otherUser = Usuari(id: '', name: '', mail: '', age: 0).obs;
  late Rx<types.TextMessage> newMessage;
  final RxList<types.TextMessage> messages = <types.TextMessage>[].obs;

  void setChatMessages(List<types.TextMessage> newMessages) {
    messages.assignAll(newMessages);
  }

  void addChatMessage(types.TextMessage message) {
    messages.insert(0, message);
  }

  Future<void> setChatId(String chatId) async {
    this.chatId.value = chatId;
  }

  Future<void> setOtherUserNameAndId(String userName, String userId) async {
    this.otherUser.value = Usuari(id: userId, name: userName, mail: '', age: 0);
  }

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
