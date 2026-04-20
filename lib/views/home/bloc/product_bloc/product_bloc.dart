import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
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
      } catch (e) {
        emit(ProductError(e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString()));
      }
    });
    on<LoadProductsByCategory>((event, emit) async {
      emit(ProductLoading(category: event.category));
      try { 
        final products = await _productRepository.fetchProductsByCategory(event.category);
        emit(ProductByCategoryLoaded(List.from( products), event.category));
      } catch (e) {
        emit(ProductError(e.toString().replaceFirst('Exception: ', '')));
      }
    });
    on<SearchProduct>((event, emit) async{
      if (event.query.trim().isEmpty) {
        emit(ProductError("Vui lòng nhập tìm kiếm...")); 
        return;
      }
      try {
        final products = await _productRepository.searchProducts(event.query);
        emit(ProductLoadedSearch(products));
      } catch (e) {
        emit(ProductError(e.toString().replaceFirst('Exception: ', '')));
      }
    }, transformer: (events, mapper) {
      return events.debounceTime(const Duration(milliseconds: 500)).flatMap(mapper);
    },
    );
    on<ClearSearch>((event, emit) => emit(ProductInitial())); 

    on<ErrorProducts>((event, emit) => emit(ProductError(event.message)));
  
  }
}
