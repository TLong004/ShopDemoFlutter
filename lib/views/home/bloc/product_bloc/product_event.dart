part of 'product_bloc.dart';

sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

final class LoadProducts extends ProductEvent {}
final class ErrorProducts extends ProductEvent {
  final String message;
  const ErrorProducts(this.message);

  @override
  List<Object> get props => [message];

}
final class LoadProductsByCategory extends ProductEvent {
  final String category;

  const LoadProductsByCategory(this.category);

  @override
  List<Object> get props => [category];
}
final class SearchProduct extends ProductEvent {
  final String query;
  const SearchProduct(this.query);

  @override
  List<Object> get props => [query];
}
class ClearSearch extends ProductEvent {}