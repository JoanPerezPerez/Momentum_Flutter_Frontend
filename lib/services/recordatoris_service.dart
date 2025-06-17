import 'package:dio/dio.dart';
import 'package:momentum/models/recordatoris_model.dart';
import 'package:momentum/services/api_service.dart';

class RecordatorisService {
  static Dio get dio => ApiService.dio;
  static final String baseUrl = ApiService.baseUrl;
  static final String recordatorisUrl = "$baseUrl/recordatoris";

  static Future<List<Recordatori>> getAllRecordatoris(String userId) async {
    final response = await dio.get(
      "$recordatorisUrl/user/$userId",
      options: Options(
        headers: {"Content-Type": "application/json"},
        validateStatus: (status) {
          return status != null && (status == 200 || status == 400);
        },
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((recordatori) {
        return Recordatori.fromJson(recordatori, recordatori['_id'] as String);
      }).toList();
    } else if (response.statusCode == 400) {
      throw Exception(response.data['error']);
    } else {
      throw Exception("Failed to fetch recordatoris");
    }
  }

  static Future<Recordatori> createRecordatori(Recordatori recordatori) async {
    final response = await dio.post(
      recordatorisUrl,
      data: recordatori.toJson(),
      options: Options(
        headers: {"Content-Type": "application/json"},
        validateStatus: (status) {
          return status != null && (status == 201 || status == 400);
        },
      ),
    );
    if (response.statusCode == 201) {
      return Recordatori.fromJson(
        response.data,
        response.data['_id'] as String,
      );
    } else if (response.statusCode == 400) {
      throw Exception(response.data['error']);
    } else {
      throw Exception("Failed to create recordatori");
    }
  }

  static Future<void> deleteRecordatori(String id) async {
    final response = await dio.delete(
      "$recordatorisUrl/$id",
      options: Options(
        headers: {"Content-Type": "application/json"},
        validateStatus: (status) {
          return status != null && (status == 204 || status == 400);
        },
      ),
    );
    if (response.statusCode != 204) {
      throw Exception("Failed to delete recordatori");
    }
  }

  static Future<Recordatori> updateRecordatori(Recordatori recordatori) async {
    final response = await dio.put(
      "$recordatorisUrl/${recordatori.id}",
      data: recordatori.toJson(),
      options: Options(
        headers: {"Content-Type": "application/json"},
        validateStatus: (status) {
          return status != null && (status == 200 || status == 400);
        },
      ),
    );
    if (response.statusCode == 200) {
      return Recordatori.fromJson(
        response.data,
        response.data['_id'] as String,
      );
    } else if (response.statusCode == 400) {
      throw Exception(response.data['error']);
    } else {
      throw Exception("Failed to update recordatori");
    }
  }
}
