import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:momentum/models/message_model.dart';

class XatService {
  static const String baseUrl = "http://localhost:8080";

  static const String xatUrl = "$baseUrl/chat";

  static Future<List<List<String>>> getPeopleWithWhomUserChatted(
    String userId,
  ) async {
    print("getting people with whom user $userId chatted");
    final response = await http.get(
      Uri.parse("$xatUrl/people/" + userId),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      print("Successful at getting people with whom user $userId chatted");
      final decoded = jsonDecode(response.body) as List;
      return decoded.map((item) => List<String>.from(item)).toList();
    } else {
      print(
        "Not successful, status code: ${response.statusCode}, response: ${response.body}",
      );
      throw Exception("Failed to get user with whom I chatted");
    }
  }

  static Future<String> getChatId(String user1Id, String user2Id) async {
    final response = await http.get(
      Uri.parse("$xatUrl/id/" + user1Id + "/" + user2Id),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      print("Successful at getting chat Id" + response.body);
      return response.body;
    } else {
      print(
        "Not successful, status code: ${response.statusCode}, response: ${response.body}",
      );
      throw Exception("Failed to get chat id");
    }
  }

  static Future<List<ChatMessage>> getMessagesofChat(String chatId) async {
    final response = await http.get(
      Uri.parse("$xatUrl/messages/" + chatId),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = await jsonDecode(response.body);
      final responseFinal =
          await jsonData.map((item) => ChatMessage.fromJson(item)).toList();
      return responseFinal;
    } else {
      throw Exception("Failed to get messages of the chat");
    }
  }

  static Future<int> sendMessage(
    String chatId,
    String userFrom,
    String message,
  ) async {
    final response = await http.post(
      Uri.parse("$xatUrl/send"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "chatId": chatId,
        "userFrom": userFrom,
        "message": message,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to send message");
    }
    return response.statusCode;
  }
}
