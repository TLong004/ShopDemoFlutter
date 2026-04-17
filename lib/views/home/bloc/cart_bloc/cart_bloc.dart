import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shopdemo/models/product.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final List<Product> _cartProducts;
  CartBloc({required List<Product> cartProducts}) : _cartProducts = cartProducts, super(CartInitial()) {
    on<LoadCart>((event, emit) {
      emit(CartLoading());
    });
    on<AddToCart>((event, emit) {
      _cartProducts.add(event.product);
      emit(CartLoaded(
        List.from(_cartProducts),
        message: "Added to cart!"
      ));
    });
  }
}
