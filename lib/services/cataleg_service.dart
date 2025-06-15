import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:momentum/models/business_model.dart';
import 'package:momentum/services/api_service.dart';

class CatalegService {
  static Dio get dio => ApiService.dio;
  static final String baseUrl = ApiService.baseUrl;

  static final String usersUrl = "$baseUrl/users";
  static final String locationUrl = "$baseUrl/location";
  static final String businessUrl = "$baseUrl/business";
  static final String workersUrl = "$baseUrl/workers";

  static Future<List<String>> getAllCities() async {
    try {
      final response = await dio.get("$locationUrl/cities");

      final List<dynamic> cityList = response.data['cities'];
      return cityList.map((city) => city.toString()).toList();
    } catch (e) {
      log('Excepció al carregar ciutats: $e');
      return [];
    }
  }

  static Future<List<BusinessWithLocations>> getAllBusiness() async {
    try {
      final response = await dio.get(businessUrl);

      final List<dynamic> businessList = response.data['businesses'];
      return businessList
          .map((json) => BusinessWithLocations.fromJson(json))
          .toList();
    } catch (e) {
      log('Excepció al carregar negocis: $e');
      return [];
    }
  }

  static Future<List<BusinessWithLocations>> getFilteredBusiness(
    Map<String, dynamic> filters,
    String userId,
  ) async {
    try {
      final response = await dio.post(
        "$businessUrl/filter/${Uri.encodeComponent(userId)}",
        data: filters,
        options: Options(headers: {'Content-Type': 'application/json'}),

      );

      final List<dynamic> businessList = response.data['businesses'];
      return businessList
          .map((json) => BusinessWithLocations.fromJson(json))
          .toList();
    } catch (e) {
      log('Excepció al filtrar negocis: $e');
      return [];
    }
  }

  static Future<List<BusinessWithLocations>> searchBusinessByName(
    String name,
  ) async {
    try {
      final response = await dio.get(
        '$businessUrl/search/${Uri.encodeComponent(name)}',
      );

      final List<dynamic> businessList = response.data['businesses'];
      return businessList
          .map((json) => BusinessWithLocations.fromJson(json))
          .toList();
    } catch (e) {
      log('Excepció en buscar business per nom: $e');
      return [];
    }
  }

  static Future<List<BusinessWithLocations>> getFavoriteBusinesses(
    String userId,
  ) async {
    try {
      final response = await dio.get(
        '$businessUrl/favorites/${Uri.encodeComponent(userId)}',
      );

      final List<dynamic> businessList = response.data['businesses'];
      return businessList
          .map((json) => BusinessWithLocations.fromJson(json))
          .toList();
    } catch (e) {
      log('Excepció en obtenir negocis favorits: $e');
      return [];
    }
  }

  static Future<List<BusinessWithLocations>> getFilteredFavoriteBusinesses(
    String userId,
    Map<String, dynamic> filters,
  ) async {
    try {
      final response = await dio.post(
        '$businessUrl/favorites/filter/$userId',
        data: filters,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final List<dynamic> businessList = response.data['businesses'];
      return businessList
          .map((json) => BusinessWithLocations.fromJson(json))
          .toList();
    } catch (e) {
      log('Excepció filtrant favorits: $e');
      return [];
    }
  }

  static Future<bool> toggleFavoriteLocation(
    String userId,
    String locationId,
  ) async {
    try {
      final response = await dio.patch(
        '$usersUrl/$userId/favorites/$locationId',
      );

      return response.statusCode == 200;
    } catch (e) {
      log('Excepció en toggleFavoriteLocation: $e');
      return false;
    }
  }
}
