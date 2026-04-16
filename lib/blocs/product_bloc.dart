import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shopdemo/blocs/product_event.dart';
import 'package:shopdemo/blocs/product_state.dart';
import 'package:shopdemo/models/category.dart';
import 'package:shopdemo/repositories/product_repository.dart';

class ProductBloc {
  final _productRepository = ProductRepository();

  final _eventController = StreamController<ProductEvent>.broadcast();
  Sink<ProductEvent> get eventSink => _eventController.sink;

  final _stateController = BehaviorSubject<ProductState>();
  Stream<ProductState> get stateStream => _stateController.stream;

  final _bannerController = BehaviorSubject<List<String>>();
  Stream<List<String>> get bannerStream => _bannerController.stream;

  final _categoryController = BehaviorSubject<List<Category>>();
  Stream<List<Category>> get categoryStream => _categoryController.stream;

  final _searchController = BehaviorSubject<ProductState>();
  Stream<ProductState> get searchStream => _searchController.stream;

  ProductBloc() {
    _eventController.stream
        .whereType<SearchProducts>()
        .debounceTime(const Duration(milliseconds: 300))
        .distinct()
        .listen(_handleSearch);
    _eventController.stream
        .where((event) => event is! SearchProducts)
        .listen(_mapEventToState);
  }

  void _mapEventToState(ProductEvent event) async {
    if (event is LoadProducts) {
      _stateController.sink.add(ProductLoading());
      try {

        final results = await Future.wait([
          _productRepository.fetchAllProducts(),
          _productRepository.fetchBanner(),
          _productRepository.fetchAllCategories(),
        ]);

        final products = results[0] as List;
        final banners = results[1] as List<String>;
        final categories = results[2] as List<Category>;

        _bannerController.sink.add(banners);
        _categoryController.sink.add(categories);
        _stateController.sink.add(ProductLoaded(products));
      } catch (e) {
        _stateController.sink.add(ProductError(e.toString()));
      }
    } 
  }

  void _handleSearch(SearchProducts event) async {
    if (event.query.isEmpty) {
      _searchController.sink.add(ProductInitial());
      return;
    }

    _searchController.sink.add(ProductLoading());
    try {
      final products = await _productRepository.searchProducts(event.query);
      if (products.isEmpty) {
        _searchController.sink.add(ProductEmpty());
        return;
      }
      _searchController.sink.add(ProductLoaded(products));
    } catch (e) {
      _searchController.sink.add(ProductError(e.toString()));
    }
  }

  void dispose() {
    _eventController.close();
    _stateController.close();
    _bannerController.close();
    _categoryController.close();
    _searchController.close();
  }
}