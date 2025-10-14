import 'package:flutter/material.dart';
import 'package:koooly_app/src/cubit/models/cart_items.dart';
import 'package:koooly_app/src/cubit/models/product.dart';
import '../services/cart_storage.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, it) => sum + it.quantity);
  double get subtotal => _items.fold(0.0, (sum, it) => sum + it.lineSubtotal);
  double get totalDiscount =>
      _items.fold(0.0, (sum, it) => sum + it.lineDiscount);
  double get total => (subtotal - totalDiscount).clamp(0, double.infinity);

  /// Add item to cart and persist
  void addToCart(Product product, {int quantity = 1, double? discount}) {
    final idx = _items.indexWhere((it) => it.product.id == product.id);
    if (idx != -1) {
      _items[idx].quantity += quantity;
    } else {
      _items.add(
          CartItem(product: product, quantity: quantity, discount: discount));
    }
    notifyListeners();
    persist();
  }

  /// Remove item from cart and persist
  void removeFromCart(String productId) {
    _items.removeWhere((it) => it.product.id == productId);
    notifyListeners();
    persist();
  }

  /// Update quantity and persist
  void updateQuantity(String productId, int quantity) {
    final idx = _items.indexWhere((it) => it.product.id == productId);
    if (idx == -1) return;
    _items[idx].quantity = quantity.clamp(1, 999);
    notifyListeners();
    persist();
  }

  /// Increase quantity by CartItem
  void increaseQuantity(CartItem item) {
    final idx = _items.indexWhere((it) => it.product.id == item.product.id);
    if (idx != -1) {
      _items[idx].quantity += 1;
      notifyListeners();
      persist();
    }
  }

  /// Decrease quantity by CartItem
  void decreaseQuantity(CartItem item) {
    final idx = _items.indexWhere((it) => it.product.id == item.product.id);
    if (idx != -1) {
      if (_items[idx].quantity > 1) {
        _items[idx].quantity -= 1;
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
      persist();
    }
  }

  /// Clear cart and persist
  void clear() {
    _items.clear();
    notifyListeners();
    CartStorage.clearCart();
  }

  /// Save cart to local storage
  Future<void> persist() async {
    await CartStorage.saveCart(_items);
  }

  /// Restore cart from local storage
  Future<void> restore() async {
    final restored = await CartStorage.loadCart();
    _items
      ..clear()
      ..addAll(restored);
    notifyListeners();
  }
}
