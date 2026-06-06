import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:naijameds/models/cart_item.dart';

class CartService {
  static List<CartItem> cartItems = [];
  static const String _cartKey = 'user_cart_items';

  static Future<void> init() async {
    await loadCart();
  }

  static Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartData = prefs.getString(_cartKey);
      if (cartData != null) {
        final List<dynamic> decodedData = jsonDecode(cartData);
        cartItems = decodedData.map((item) => CartItem.fromJson(item)).toList();
      }
    } catch (e) {
      print("Error loading cart: $e");
      cartItems = [];
    }
  }

  static Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(cartItems.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, encodedData);
  }

  static Future<bool> addToCart(CartItem item) async {
    final existingIndex = cartItems.indexWhere((e) => e.name == item.name);
    if (existingIndex != -1) {
      cartItems[existingIndex].quantity += 1;
    } else {
      cartItems.add(item);
    }
    await _saveCart();
    return true;
  }

  static Future<void> updateQuantity(CartItem item, int delta) async {
    final index = cartItems.indexOf(item);
    if (index != -1) {
      cartItems[index].quantity += delta;
      if (cartItems[index].quantity <= 0) {
        cartItems.removeAt(index);
      }
      await _saveCart();
    }
  }

  static Future<void> deleteCart(CartItem item) async {
    cartItems.removeWhere((element) => element.name == item.name);
    await _saveCart();
  }

  static Future<void> clearCart() async {
    cartItems.clear();
    await _saveCart();
  }

  static double getTotalPrice() {
    double total = 0;
    for (var item in cartItems) {
      final priceString = item.price.replaceAll(RegExp(r'[^0-9.]'), '');
      final price = double.tryParse(priceString) ?? 0;
      total += price * item.quantity;
    }
    return total;
  }
}
