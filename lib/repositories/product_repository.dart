import 'package:dio/dio.dart';
import 'package:shopdemo/models/product.dart';
import 'package:shopdemo/services/product_service.dart';
import 'package:shopdemo/models/category.dart';

class ProductRepository {
  ProductService _productService = ProductService();

  Future<List<Product>> fetchAllProducts() async {
    try {
      final response = await _productService.fetchAllProducts();
      final List<dynamic> data = response.data['products'];
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Lỗi khi tải sản phẩm: ${e.error.toString()}');
    }
  }

  Future<List<String>> fetchBanners() async {
    try {
      final response = await _productService.fetchBanner();
      final List<dynamic> data = response.data['products'];
      return data.map<String>((json) => json['thumbnail'] as String).toList();
    } on DioException catch (e) {
      throw Exception('Lỗi khi tải banner: ${e.error.toString()}');
    }
  }

  Future<List<Category>> fetchAllCategories() async {
    try {
      final response = await _productService.fetchAllCategories();
      final List<dynamic> data = response.data;
      return data.map((json) => Category.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Lỗi khi tải danh mục: ${e.error.toString()}');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _productService.searchProducts(query);
      final List<dynamic> data = response.data['products'];
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Lỗi khi tìm kiếm sản phẩm: ${e.error.toString()}');
    }
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      if (category == 'All') {
        return await fetchAllProducts();
      }
      final response = await _productService.fetchProductsByCategory(category);
      final List<dynamic> data = response.data['products'];
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Lỗi khi tải sản phẩm theo danh mục: ${e.error.toString()}');
    }
  }
  
}