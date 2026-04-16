import 'package:dio/dio.dart';
import 'package:shopdemo/services/dio_client.dart';

class ProductService {
  final Dio _dio = DioClient.instance();

  Future<Response> fetchAllProducts() async {
    try {
      final response = await _dio.get('');
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> fetchBanner() async {
    try {
      final response = await _dio.get('?limit=5');
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> fetchAllCategories() async {
    try {
      final response = await _dio.get('/categories');
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> searchProducts(String query) async {
    try {
      final response = await _dio.get('/search', queryParameters: {'q': query});
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionError) return "Lỗi kết nối quá hạn.";
    return e.message ?? "Đã xảy ra lỗi không xác định.";
  }
}