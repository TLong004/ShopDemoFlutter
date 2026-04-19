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
final class RemoveToCart extends CartEvent {
  final Product product;

  const RemoveToCart(this.product);

  @override
  List<Object> get props => [product];
}
final class MarkCartAsViewed extends CartEvent{}
final class IncreaseQuantity extends CartEvent {
  final Product product;

  const IncreaseQuantity(this.product);

  @override
  List<Object> get props => [product];
}
final class DecreaseQuantity extends CartEvent {
  final Product product;

  const DecreaseQuantity(this.product);

  @override
  List<Object> get props => [product];
}
final class UpdateQuantity extends CartEvent {
  final Product product;
  final int newQuantity;
  UpdateQuantity(this.product, this.newQuantity);
}
