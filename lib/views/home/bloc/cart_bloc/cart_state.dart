part of 'cart_bloc.dart';

sealed class CartState extends Equatable {
  const CartState();
  
  @override
  List<Object> get props => [];
}

final class CartInitial extends CartState {}
final class CartLoading extends CartState {}
final class CartLoaded extends CartState {
  List<Product> products;
  String? message;
  CartLoaded(this.products, {this.message});

  @override
  List<Object> get props => [products, message ?? ''];
}