import 'package:dio/dio.dart';

class DioClient {
  static Dio instance() {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://dummyjson.com/products',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
    ));
    return dio;
  }
}