import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shopdemo/models/product.dart';
import 'package:shopdemo/services/shared_prefs_helper.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    
    on<AddToCart>((event, emit) {
      final newMap = Map<int, Product>.from(state.productMap);
      final productId = event.product.id;

      if (newMap.containsKey(productId)) {
        newMap[productId] = newMap[productId]!.copyWith(
          quantity: newMap[productId]!.quantity + 1,
        );
      } else {
        newMap[productId] = event.product;
      }

      emit(state.copyWith(
        productMap: newMap,
        unviewedCount: state.unviewedCount + 1,
        status: CartStatus.success,
        message: "Đã thêm vào giỏ hàng",
      ));

      emit(state.copyWith(status: CartStatus.initial, message: null));
    });

     on<IncreaseQuantity>((event, emit) {
      final newMap = Map<int, Product>.from(state.productMap);
      final productId = event.product.id;

      if (newMap.containsKey(productId)) {
        newMap[productId] = newMap[productId]!.copyWith(
          quantity: newMap[productId]!.quantity + 1,
        );
      } else {
        newMap[productId] = event.product;
      }

      emit(state.copyWith(
        productMap: newMap,
        unviewedCount: 0,
        status: CartStatus.increaseSuccess,
        message: null,
      ));

      emit(state.copyWith(status: CartStatus.initial, message: null));
    });



   on<RemoveToCart>((event, emit) {
    final newMap = Map<int, Product>.from(state.productMap);
    final productId = event.product.id;

    newMap.remove(productId);
        
        emit(state.copyWith(
          productMap: newMap,
          status: CartStatus.deleteSuccess, 
          message: "Đã xóa ${event.product.title} khỏi giỏ hàng",
        ));

    emit(state.copyWith(status: CartStatus.initial, message: null));
  });

  on<DecreaseQuantity>((event, emit) {
    final newMap = Map<int, Product>.from(state.productMap);
    final productId = event.product.id;

    if (newMap.containsKey(productId)) {
      final currentProduct = newMap[productId]!;

      if (currentProduct.quantity > 1) {
        newMap[productId] = currentProduct.copyWith(
          quantity: currentProduct.quantity - 1,
        );
        
        emit(state.copyWith(
          productMap: newMap,
          status: CartStatus.decreaseSuccess,
          message: null,
        ));
      } else {
        newMap.remove(productId);
        
        emit(state.copyWith(
          productMap: newMap,
          status: CartStatus.deleteSuccess, 
          message: "Đã xóa ${event.product.title} khỏi giỏ hàng",
        ));
      }
    }

    emit(state.copyWith(status: CartStatus.initial, message: null));
  });
  
  on<UpdateQuantity>((event, emit) {
    final newMap = Map<int, Product>.from(state.productMap);
    final id = event.product.id;

    if (event.newQuantity > 0) {
      newMap[id] = newMap[id]!.copyWith(quantity: event.newQuantity);
    } else {
      newMap.remove(id); 
    }

    emit(state.copyWith(productMap: newMap, status: CartStatus.updateSuccess));
    emit(state.copyWith(status: CartStatus.initial));
  });

    on<MarkCartAsViewed>((event, emit) {
      emit(state.copyWith(unviewedCount: 0));
    });

    on<StartCheckout>((event, emit) async {
      final updatedMap = state.productMap.map((id, product) {
        SharedPrefsHelper.saveCheckedOutProductId(id);
        return MapEntry(id, product.copyWith(isCheckOut: true));
      });
      
      emit(state.copyWith(
        productMap: updatedMap,
        isCheckoutMode: true,
      ));
    });


  }
}