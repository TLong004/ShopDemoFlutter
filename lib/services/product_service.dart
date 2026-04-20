import 'package:dio/dio.dart';
import 'package:shopdemo/services/dio_client.dart';

class ProductService {
  final Dio _dio = DioClient.instance();

  Future<Response> fetchAllProducts() async {
    return await _dio.get('');
  }

  Future<Response> fetchBanner() async {
    return await _dio.get('?limit=5');
  }

  Future<Response> fetchAllCategories() async {
    return await _dio.get('/categories');
  }

  Future<Response> searchProducts(String query) async {
    return await _dio.get('/search', queryParameters: {'q': query});
  }

  Future<Response> fetchProductsByCategory(String category) async {
    return await _dio.get('/category/$category');
  }
}