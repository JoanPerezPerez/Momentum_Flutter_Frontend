import 'dart:convert';
import 'package:momentum/models/message_model.dart';
import 'package:dio/dio.dart';
import 'package:momentum/services/api_service.dart';

class XatService {
  static const String baseUrl = "http://localhost:8080";
  static Dio get dio => ApiService.dio;

  static const String xatUrl = "$baseUrl/chat";

  static Future<List<List<String>>> getPeopleWithWhomUserChatted(
    String userId,
  ) async {
    final response = await dio.get(
      "$xatUrl/people/" + userId,
      options: Options(headers: {"Content-Type": "application/json"}),
    );
    if (response.statusCode == 200) {
      final List<dynamic> rawPeople = response.data['people'];
      final List<List<String>> decoded =
          rawPeople.map<List<String>>((item) {
            return List<String>.from(item);
          }).toList();
      return decoded;
    } else {
      throw Exception("Failed to get user with whom I chatted");
    }
  }

  static Future<String> getChatId(String user1Id, String user2Id) async {
    final response = await dio.get(
      "$xatUrl/id/" + user1Id + "/" + user2Id,
      options: Options(headers: {"Content-Type": "application/json"}),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception("Failed to get chat id");
    }
  }

  static Future<List<ChatMessage>> getMessagesofChat(String chatId) async {
    final response = await dio.get(
      "$xatUrl/messages/$chatId",
      options: Options(headers: {"Content-Type": "application/json"}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = response.data;
      final responseFinal =
          jsonData.map((item) => ChatMessage.fromJson(item)).toList();
      return responseFinal;
    } else {
      throw Exception("Failed to get messages of the chat");
    }
  }

  static Future<int?> sendMessage(
    String chatId,
    String userFrom,
    String message,
  ) async {
    final response = await dio.post(
      "$xatUrl/send",
      options: Options(headers: {"Content-Type": "application/json"}),
      data: jsonEncode({
        "chatId": chatId,
        "userFrom": userFrom,
        "message": message,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to send message");
    }
    return response.statusCode ?? null;
  }
}
