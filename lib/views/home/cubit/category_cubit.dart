import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shopdemo/models/category.dart';
import 'package:shopdemo/repositories/product_repository.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final ProductRepository _productRepository;
  CategoryCubit({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(CategoryInitial());

  Future<void> loadCategories() async {
    emit(CategoryLoading());
    try {
      final categories = await _productRepository.fetchAllCategories();
      final allCategory = Category(name: 'All', slug: 'All');
      final updatedCategories = [allCategory, ...categories];
      emit(CategoryLoaded(updatedCategories));
    } catch (e) {
      emit(CategoryError('Failed to load categories.')); 
    }
  }
}
