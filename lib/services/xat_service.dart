import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:momentum/models/message_model.dart';
import 'package:dio/dio.dart';
import 'package:momentum/services/api_service.dart';
import 'package:momentum/models/worker_model.dart' as myWorker;

class XatService {
  static Dio get dio => ApiService.dio;
  static final String baseUrl = ApiService.baseUrl;
  static final String xatUrl = "$baseUrl/chat";
  static final String locationUrl = "$baseUrl/location";

  static Future<List<List<String>>> getPeopleWithWhomUserChatted(
    String userId,
  ) async {
    final response = await dio.get(
      "$xatUrl/people/user/" + userId,
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

  static Future<List<myWorker.Worker>> getPossibleWorkers(
    String locationId,
  ) async {
    final response = await dio.get(
      "$locationUrl/$locationId/workers",
      options: Options(headers: {"Content-Type": "application/json"}),
    );

    if (response.statusCode == 201) {
      final List<dynamic> data = response.data;
      final datafinal =
          data.map((worker) => myWorker.Worker.fromJson(worker)).toList();
      return datafinal;
    }
    throw new Exception("No Workers found");
  }

  static Future<String> startXatUser(
    String userId,
    String otherId,
    String otherType,
  ) async {
    final response = await dio.post(
      "$xatUrl/create",
      options: Options(headers: {"Content-Type": "application/json"}),
      data: jsonEncode({
        "user1ID": userId,
        "user2ID": otherId,
        "typeOfUser1": "user",
        "typeOfUser2": otherType,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception("Failed to send message");
    }
    print("\n\n\n\n\n catID");
    print(response.data['chat']['_id']);
    return response.data['chat']['_id'];
  }

  static Future<String> getInfoToStartXat(String businessId) async {
    final response = await dio.get(
      "$baseUrl/business/name/$businessId",
      options: Options(headers: {"Content-Type": "application/json"}),
    );
    if (response.statusCode == 200) {
      print("\n\n\n\n\n name for the business");
      print(response.data['name']);
      return response.data['name'];
    } else {
      throw Exception("Failed to get data");
    }
  }
}
