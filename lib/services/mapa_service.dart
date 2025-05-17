import 'package:dio/dio.dart';
import 'package:momentum/models/location_model.dart';
import 'package:momentum/services/api_service.dart';

class MapService {
  static const String baseUrl = "http://localhost:8080";
  static Dio get dio => ApiService.dio;

  static const String usersUrl = "$baseUrl/users";
  static const String loactionUrl = "$baseUrl/location";
  static const String businessUrl = "$baseUrl/business";
  static const String workersUrl = "$baseUrl/workers";

  static Future<List<ILocation>> getAllLocationsByServiceType(
    String locationServiceType,
  ) async {
    final response = await dio.get(
      "$loactionUrl/serviceType/" + locationServiceType.toString(),
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
