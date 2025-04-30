import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:momentum/models/location_model.dart';

class MapService {
  static const String baseUrl = "http://localhost:8080";

  static const String usersUrl = "$baseUrl/users";
  static const String loactionUrl = "$baseUrl/location";
  static const String businessUrl = "$baseUrl/business";
  static const String workersUrl = "$baseUrl/workers";

  static Future<List<ILocation>> getAllLocationsByServiceType(
    String locationServiceType,
  ) async {
    print("Getting all the locations for service type: $locationServiceType");
    final response = await http.get(
      Uri.parse("$loactionUrl/serviceType/" + locationServiceType.toString()),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 400) {
      print("Wrong service type");
      throw Exception("Wrong service type");
    } else if (response.statusCode == 500) {
      print("Server error");
      throw Exception("Server error");
    } else {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        final datafinal =
            data.map((location) => ILocation.fromJson(location)).toList();
        return datafinal;
      } catch (e) {
        print("Error parsing response: $e");
        throw Exception("Error parsing response: $e");
      }
    }
  }

  /*
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
  } */
}
