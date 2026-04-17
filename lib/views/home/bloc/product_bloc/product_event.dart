part of 'product_bloc.dart';

sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

final class LoadProducts extends ProductEvent {}
final class RefreshProducts extends ProductEvent {}
final class ErrorProducts extends ProductEvent {}
final class LoadProductsByCategory extends ProductEvent {
  final String category;

  const LoadProductsByCategory(this.category);

  @override
  List<Object> get props => [category];
}
