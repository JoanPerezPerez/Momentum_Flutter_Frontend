import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:momentum/models/business_model.dart';
import 'package:momentum/services/api_service.dart';

class CatalegService {
  static const String baseUrl = "http://localhost:8080";
  static Dio get dio => ApiService.dio;

  static const String usersUrl = "$baseUrl/users";
  static const String loactionUrl = "$baseUrl/location";
  static const String businessUrl = "$baseUrl/business";
  static const String workersUrl = "$baseUrl/workers";

  static Future<List<String>> getAllCities() async {
    try {
      final response = await http.get(Uri.parse("$loactionUrl/cities"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> cityList = body['cities'];
        return cityList.map((city) => city.toString()).toList();
      } else {
        log('Error carregant ciutats: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Excepció al carregar ciutats: $e');
      return [];
    }
  }

  static Future<List<BusinessWithLocations>> getAllBusiness() async {
    try {
      final response = await http.get(Uri.parse(businessUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> businessList = body['businesses'];

        return businessList
            .map((json) => BusinessWithLocations.fromJson(json))
            .toList();
      } else {
        log('Error carregant negocis: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Excepció al carregar negocis: $e');
      return [];
    }
  }

  static Future<List<BusinessWithLocations>> getFilteredBusiness(
    Map<String, dynamic> filters,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$businessUrl/filter"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(filters),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> businessList = body['businesses'];
        return businessList
            .map((json) => BusinessWithLocations.fromJson(json))
            .toList();
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        log('Filtrat rebut però sense resultats: ${body['message']}');
        return [];
      } else {
        log('Error al filtrar negocis: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Excepció al filtrar negocis: $e');
      return [];
    }
  }
  static Future<List<BusinessWithLocations>> searchBusinessByName(String name) async {
    try {
      final uri = Uri.parse('$businessUrl/search/${Uri.encodeComponent(name)}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> businessList = body['businesses'];
        return businessList
            .map((json) => BusinessWithLocations.fromJson(json))
            .toList();
      } else if (response.statusCode == 404) {
        log('No s’ha trobat cap business o location amb aquest nom');
        return [];
      } else {
        log('Error en buscar business: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Excepció en buscar business per nom: $e');
      return [];
    }
  }
  static Future<List<BusinessWithLocations>> getFavoriteBusinesses(String userId) async {
  try {
    final uri = Uri.parse('$businessUrl/favorites/${Uri.encodeComponent(userId)}');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> businessList = body['businesses'];
      return businessList
          .map((json) => BusinessWithLocations.fromJson(json))
          .toList();
    } else if (response.statusCode == 404) {
      log('No s’han trobat negocis favorits per aquest usuari');
      return [];
    } else {
      log('Error al obtenir negocis favorits: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    log('Excepció en obtenir negocis favorits: $e');
    return [];
  }
}
  static Future<List<BusinessWithLocations>> getFilteredFavoriteBusinesses(String userId, Map<String, dynamic> filters) async {
    try {
      final uri = Uri.parse('$businessUrl/favorites/filter/$userId');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(filters),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> businessList = body['businesses'];
        return businessList.map((json) => BusinessWithLocations.fromJson(json)).toList();
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        log('Sense resultats: ${body['message']}');
        return [];
      } else {
        log('Error HTTP filtrant favorits: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Excepció filtrant favorits: $e');
      return [];
    }
  }
  static Future<bool> toggleFavoriteLocation(String userId, String locationId) async {
    try {
      final uri = Uri.parse('$usersUrl/$userId/favorites/$locationId'); 
      final response = await http.patch(uri);

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        log('Usuari no trobat');
        return false;
      } else {
        log('Error al actualitzar favorit: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Excepció en toggleFavoriteLocation: $e');
      return false;
    }
  }
}
