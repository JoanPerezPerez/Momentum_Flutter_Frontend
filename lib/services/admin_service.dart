import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:momentum/models/location_model.dart';
import 'package:momentum/models/worker_model.dart';
import 'package:momentum/services/api_service.dart';

class AdminService {
  static Dio get dio => ApiService.dio;
  static final String baseUrl = ApiService.baseUrl;
  static final String usersUrl = "$baseUrl/users";
  static final String locationUrl = "$baseUrl/location";
  static final String businessUrl = "$baseUrl/business";
  static final String workersUrl = "$baseUrl/workers";

  static Future<void> registerLocation(ILocation location) async {
    final response = await dio.post(
      "$businessUrl/locations/",
      options: Options(
        headers: {"Content-Type": "application/json"},
        validateStatus: (status) {
          return status != null && (status == 201 || status == 405);
        },
      ),
      data: jsonEncode({"locationData": location}),
    );
    if (response.statusCode == 405) {
      print(response.data["error"]);
      throw Exception(response.data["error"]);
    } else if (response.statusCode == 500) {
      throw Exception("Server error");
    }
  }

  static Future<void> registerWorker(Worker worker, String locationName) async {
    final response = await dio.post(
      "$workersUrl",
      options: Options(
        headers: {"Content-Type": "application/json"},
        validateStatus: (status) {
          return status != null && (status == 201 || status == 405);
        },
      ),
      data: jsonEncode({"worker": worker, "location": locationName}),
    );
    if (response.statusCode == 405) {
      throw Exception(response.data["error"]);
    } else if (response.statusCode == 500) {
      throw Exception("Server error");
    }
  }
}
