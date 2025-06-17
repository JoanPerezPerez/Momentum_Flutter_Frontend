import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:momentum/models/appointment_model.dart';
import 'package:momentum/services/api_service.dart';

class IaService extends GetxService {
  static Dio get dio => ApiService.dio;
  static final String baseUrl = ApiService.baseUrl;
  static final String IAUrl = "$baseUrl/ia";

  static Future<List<AppointmentModel>> sendOptimization(
    String textToSend,
    String userId,
  ) async {
    try {
      final response = await dio.post(
        "$IAUrl/optimizeAppointments",
        data: {"textToOptimize": textToSend, "userId": userId},
        options: Options(
          headers: {"Content-Type": "application/json"},
          extra: {"withCredentials": true},
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> rawList = response.data;
        return rawList.map((json) => AppointmentModel.fromJson(json)).toList();
      } else {
        final error = response.data['error'];
        throw Exception("Optimization failed $error");
      }
    } catch (e) {
      throw Exception("Optimization failed: ${e.toString()}");
    }
  }

  static Future<String> test(String textToSend) async {
    try {
      final response = await dio.post(
        "$IAUrl/test",
        data: {"textToOptimize": textToSend},
        options: Options(
          headers: {"Content-Type": "application/json"},
          extra: {"withCredentials": true},
        ),
      );
      if (response.statusCode == 200) {
        final answer = response.data['textOptimized'];
        print(answer);
        return answer as String;
      } else {
        throw Exception(
          "Optimization failed with status ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Optimization failed: ${e.toString()}");
    }
  }
}
