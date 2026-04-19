part of 'cart_bloc.dart';

enum CartStatus { initial, loading, success, error, deleteSuccess, increaseSuccess, decreaseSuccess, updateSuccess }

class CartState extends Equatable {
  final Map<int, Product> productMap;
  final int unviewedCount; 
  final CartStatus status;
  final String? message;

  List<Product> get products => productMap.values.toList();

  const CartState({
    this.productMap = const {},
    this.unviewedCount = 0,
    this.status = CartStatus.initial,
    this.message,
  });

  @override
  List<Object?> get props => [productMap, unviewedCount, status, message];

  double get totalPrice {
    return productMap.values.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  CartState copyWith({
    Map<int, Product>? productMap,
    int? unviewedCount,
    CartStatus? status,
    String? message,
  }) {
    return CartState(
      productMap: productMap ?? this.productMap,
      unviewedCount: unviewedCount ?? this.unviewedCount,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}