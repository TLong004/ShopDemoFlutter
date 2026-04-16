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
    } catch (e) {
      throw Exception('Lỗi khi tải sản phẩm: $e');
    }
  }

  Future<List<String>> fetchBanner() async {
    try {
      final response = await _productService.fetchBanner();
      final List<dynamic> data = response.data['products'];
      return data.map<String>((json) => json['thumbnail'] as String).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải banner: $e');
    }
  }

  Future<List<Category>> fetchAllCategories() async {
    try {
      final response = await _productService.fetchAllCategories();
      final List<dynamic> data = response.data;
      return data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh mục: $e');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _productService.searchProducts(query);
      final List<dynamic> data = response.data['products'];
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tìm kiếm sản phẩm: $e');
    }
  }
  
}