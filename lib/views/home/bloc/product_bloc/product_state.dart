part of 'product_bloc.dart';

sealed class ProductState extends Equatable {
  const ProductState();
  
  @override
  List<Object> get props => [];
}

final class ProductInitial extends ProductState {}
final class ProductLoading extends ProductState {
  String category;
  ProductLoading({required this.category});

  @override
  List<Object> get props => [category];
}
final class ProductLoaded extends ProductState {
  List<Product> products;
  String category;
  ProductLoaded(this.products, this.category);

  @override
  List<Object> get props => [products, category];
}
final class ProductError extends ProductState {
  String message;
  ProductError(this.message);

  @override
  List<Object> get props => [message];
}
final class ProductByCategoryLoaded extends ProductState {
  List<Product> products;
  String category;
  ProductByCategoryLoaded(this.products, this.category);

  @override
  List<Object> get props => [products, category];
}