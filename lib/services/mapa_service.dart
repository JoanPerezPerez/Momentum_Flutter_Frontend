import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:momentum/models/location_model.dart';
import 'package:momentum/services/api_service.dart';

class MapService {
  static late String baseUrl;
  static Dio get dio => ApiService.dio;

  static late String usersUrl;
  static late String locationUrl;
  static late String businessUrl;
  static late String workersUrl;

  static Future<void> init() async {
    baseUrl = dotenv.env['URL'] ?? "http://localhost:8080";
    usersUrl = "$baseUrl/users";
    locationUrl = "$baseUrl/location";
    businessUrl = "$baseUrl/business";
    workersUrl = "$baseUrl/workers";
  }

  static Future<List<ILocation>> getAllLocationsByServiceType(
    String locationServiceType,
  ) async {
    final response = await dio.get(
      "$locationUrl/serviceType/" + locationServiceType.toString(),
      options: Options(headers: {"Content-Type": "application/json"}),
    );
    if (response.statusCode == 400) {
      throw Exception("Wrong service type");
    } else if (response.statusCode == 500) {
      throw Exception("Server error");
    } else {
      try {
        final List<dynamic> data = response.data;
        final datafinal =
            data.map((location) => ILocation.fromJson(location)).toList();
        return datafinal;
      } catch (e) {
        throw Exception("Error parsing response: $e");
      }
    }
  }
}
