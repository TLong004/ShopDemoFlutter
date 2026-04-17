part of 'cart_bloc.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}
final class LoadCart extends CartEvent {}
final class AddToCart extends CartEvent {
  final Product product;

  const AddToCart(this.product);

  @override
  List<Object> get props => [product];
}