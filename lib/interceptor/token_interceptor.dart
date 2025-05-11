import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:momentum/routes/app_routes.dart';
import 'package:momentum/screens/login_screen.dart';
import 'package:momentum/services/api_service.dart';

class TokenInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final errorMessage = err.response?.data['error'];
      if (errorMessage != null && errorMessage == "Access token expired") {
        print("Acces Token is expired, getting a new one");
        try {
          final newToken = await ApiService.refreshToken();
          await ApiService.secureStorage.write(
            key: 'access_token',
            value: newToken,
          );
          final RequestOptions requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final response = await ApiService.dio.fetch(requestOptions);
          return handler.resolve(response);
        } catch (exception) {
          print(
            "something went wrong when trying to get the token" +
                exception.toString(),
          );
          Get.toNamed(AppRoutes.cataleg);
          Navigator.push(
            Get.context!,
            MaterialPageRoute(builder: (context) => ButtonTextChange()),
          );
        }
      } else if (errorMessage != null &&
          errorMessage == "Access token required") {
        print(
          "Acces token is required, trying again with acces token included",
        );
        final accessToken = await ApiService.secureStorage.read(
          key: 'access_token',
        );
        if (accessToken != null) {
          final RequestOptions requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $accessToken';
          final response = await ApiService.dio.fetch(requestOptions);
          return handler.resolve(response);
        }
      }
    }
    return handler.next(err);
  }
}
