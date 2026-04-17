import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:shopdemo/models/product.dart';
import 'package:shopdemo/repositories/product_repository.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({required ProductRepository productRepository}) : _productRepository = productRepository, super(ProductInitial()) {
    on<LoadProducts>((event, emit) async {
      emit(ProductLoading(category: 'All'));
      try {
        final products = await _productRepository.fetchAllProducts();
        emit(ProductLoaded(products, 'All'));
      } on DioException catch (e) {
        emit(ProductError(e.error.toString()));
      }
    });
    on<LoadProductsByCategory>((event, emit) async {
      emit(ProductLoading(category: event.category));
      try { 
        final products = await _productRepository.fetchProductsByCategory(event.category);
        emit(ProductByCategoryLoaded(List.from( products), event.category));
      } on DioException catch (e) {
        emit(ProductError(e.error.toString()));
      }
    });

  }
}
