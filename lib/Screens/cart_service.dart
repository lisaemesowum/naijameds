

import 'package:naijameds/models/cart_item.dart';

class CartService {

  static final List<CartItem> cartItems = [];

  static bool addToCart(CartItem item) {

    // Check if already exists
    final existingIndex = cartItems.indexWhere(
          (e) => e.name == item.name,
    );

    if (existingIndex != -1) {

      return false;

    } else {

      cartItems.add(item);

      return true;

    }
  }

  static double getTotalPrice() {

    double total = 0;

    for (var item in cartItems) {

      final price = double.tryParse(
        item.price.replaceAll("₦", ""),
      ) ?? 0;

      total += price * item.quantity;
    }

    return total;
  }

//    remove cart
static void deleteCart(CartItem item){
    if(cartItems.contains(item)){
      cartItems.remove(item);
    }
}

}

