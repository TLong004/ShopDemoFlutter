import 'package:dio/dio.dart';
import 'package:shopdemo/services/dio_exception.dart';

class DioClient {
  static Dio instance() {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://dummyjson.com/products',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        final errorDio = DioExceptions.fromDioError(error);
        return handler.next(error.copyWith(
          error: errorDio,
        ));
      },
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