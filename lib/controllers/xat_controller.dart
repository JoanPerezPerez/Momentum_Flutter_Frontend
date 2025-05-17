import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/models/user_model.dart';
import 'package:momentum/services/xat_service.dart';
import 'package:momentum/models/message_model.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:momentum/controllers/socket_controller.dart';

class XatController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  late SocketController socketController;

  var users = <List<String>>[].obs;
  var chatId = ''.obs;
  var isLoading = false.obs;
  var chatMessages = <ChatMessage>[].obs;
  var correctlySent = false.obs;
  Rx<Usuari> otherUser = Usuari(id: '', name: '', mail: '', age: 0).obs;
  late Rx<types.TextMessage> newMessage;
  final RxList<types.TextMessage> messages = <types.TextMessage>[].obs;
  late types.User user;

  @override
  void onInit() async {
    super.onInit();
  }

  void setUser() {
    user = types.User(id: authController.currentUser.value.name);
  }

  void login() async {
    socketController.sendMessage(
      'user_login',
      authController.currentUser.value.name,
    );
  }

  void setChatMessages(List<types.TextMessage> newMessages) {
    messages.assignAll(newMessages);
  }

  void addChatMessage(types.TextMessage message) {
    messages.insert(0, message);
  }

  void fetchMessages() async {
    final cleanId = chatId.replaceAll('"', '');
    await getChatMessages(cleanId);
    final messages = convertToTextMessages(chatMessages);
    setChatMessages(messages);
  }

  void handleSendPressed(types.PartialText message) async {
    final cleanId = chatId.replaceAll('"', '');
    await sendMessage(
      cleanId,
      authController.currentUser.value.name,
      message.text,
    );
    if (correctlySent.value == false) {
      Get.snackbar("Error", "Failed to send message");
      return;
    }
    socketController = Get.find<SocketController>();
    socketController.sendMessage('new_message', {
      'chatId': cleanId,
      'sender': authController.currentUser.value.name,
      'message': message.text,
    });
    final textMessage = types.TextMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.text,
    );
    messages.insert(0, textMessage);
    correctlySent.value = false;
  }

  List<types.TextMessage> convertToTextMessages(List<dynamic> messagesFromApi) {
    final uuid = const Uuid();
    return messagesFromApi.map((msg) {
      if (msg is ChatMessage) {
        return types.TextMessage(
          id: uuid.v4(),
          author: types.User(id: msg.from),
          createdAt: msg.timestamp.millisecondsSinceEpoch,
          text: msg.text,
        );
      } else if (msg is Map<String, dynamic>) {
        final timestamp = DateTime.tryParse(msg['timestamp']?.toString() ?? '');
        print('userId: ${msg['from']?.toString()}');
        return types.TextMessage(
          id: msg['from']?.toString() ?? uuid.v4(),
          author: types.User(id: msg['from'].toString() ?? 'unknown'),
          createdAt: timestamp?.millisecondsSinceEpoch ?? 0,
          text: msg['text'] ?? '',
        );
      } else {
        throw Exception("Format de missatge desconegut: ${msg.runtimeType}");
      }
    }).toList();
  }

  Future<void> setChatId(String chatId) async {
    this.chatId.value = chatId;
  }

  Future<void> setOtherUserNameAndId(String userName, String userId) async {
    this.otherUser.value = Usuari(id: userId, name: userName, mail: '', age: 0);
  }

  Future<void> getUserWithWhomUserChatted() async {
    isLoading.value = true;
    try {
      final response = await XatService.getPeopleWithWhomUserChatted(
        authController.currentUser.value.id as String,
      );
      users.value = response;
    } catch (e) {
      Get.snackbar("Error", "failed: ${e.toString()}");
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
