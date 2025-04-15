import 'dart:convert';
import 'package:http/http.dart' as http;

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
      print("Successful, response: ${response.body}");
      final decoded = jsonDecode(response.body) as List;
      return decoded.map((item) => List<String>.from(item)).toList();
    } else {
      print(
        "Not successful, status code: ${response.statusCode}, response: ${response.body}",
      );
      throw Exception("Failed to get user with whom I chatted");
    }
  }
}
