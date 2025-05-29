import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:momentum/models/location_model.dart';
import 'package:momentum/services/api_service.dart';

class MapService {
  static Dio get dio => ApiService.dio;
  static final String baseUrl = ApiService.baseUrl;
  static final String usersUrl = "$baseUrl/users";
  static final String locationUrl = "$baseUrl/location";
  static final String businessUrl = "$baseUrl/business";
  static final String workersUrl = "$baseUrl/workers";

  static Future<List<ILocation>> getAllLocationsByServiceType(
    String locationServiceType,
  ) async {
    final response = await dio.get(
      "$locationUrl/serviceType/$locationServiceType",
      options: Options(headers: {"Content-Type": "application/json"}),
    );
    if (response.statusCode == 400) {
      throw Exception("Wrong service type");
    } else if (response.statusCode == 500) {
      throw Exception("Server error");
    }
    try {
      final List<dynamic> data = response.data;
      return data.map((json) => ILocation.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Error parsing response: $e");
    }
  }


  static Future<ILocation> getLocationById(String id) async {
    final response = await dio.get(
      "$locationUrl/$id",
      options: Options(headers: {"Content-Type": "application/json"}),
    );

    if (response.statusCode == 404) {
      throw Exception("Location not found (404)");
    } else if (response.statusCode == 400) {
      throw Exception("Bad request (400)");
    } else if (response.statusCode == 500) {
      throw Exception("Server error (500)");
    }

    try {
      return ILocation.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception("Error parsing location response: $e");
    }
  }
}
