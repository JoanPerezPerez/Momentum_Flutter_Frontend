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
