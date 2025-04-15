import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;



class ApiService {
  static const String baseUrl = "http://localhost:8080";

  static const String usersUrl = "$baseUrl/users";
  static const String authUrl = "$baseUrl/auth";


  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    print("Login attempt with email: $email and password: $password");
    final response = await http.post(
      Uri.parse("$authUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name_or_mail": email, "password": password}),
    );
    print(response);
    if (response.statusCode == 200) {
      print("Login successful, response: ${response.body}");
      return jsonDecode(response.body);
    } else {
      print(
        "Login failed, status code: ${response.statusCode}, response: ${response.body}",
      );
      throw Exception("Login failed");
    }
  }

  static Future<int> register(
    String name,
    String email,
    String password,
    int age,
  ) async {
    print(
      "Register attempt with name: $name, email: $email, password: $password, age: $age",
    );
    final response = await http.post(
      Uri.parse("$usersUrl"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "age": age,
        "mail": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return 1;
    } else {
      throw Exception("Registration failed");
    }
  }
}
