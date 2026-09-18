import 'package:final_project/services/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, this.quantity = 1});

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartCubit extends Cubit<List<CartItem>> {
  CartCubit() : super([]);

  void addToCart(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      final updatedList = List<CartItem>.from(state);
      updatedList[index] = updatedList[index].copyWith(
        quantity: updatedList[index].quantity + 1,
      );
      emit(updatedList);
    } else {
      emit([...state, CartItem(product: product, quantity: 1)]);
    }
  }

  void decreaseQuantity(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      if (state[index].quantity > 1) {
        final updatedList = List<CartItem>.from(state);
        updatedList[index] = updatedList[index].copyWith(
          quantity: updatedList[index].quantity - 1,
        );
        emit(updatedList);
      } else {
        removeFromCart(product);
      }
    }
  }

  void removeFromCart(Product product) {
  final updatedList = state
        .where((item) => item.product.id != product.id)
        .toList();
    emit(updatedList);
  }

  void clearCart() {
    emit([]);
  }

  double get totalPrice {
    return state.fold(
      0.0,
      (total, item) => total + (item.product.price * item.quantity),
    );
  }
}
