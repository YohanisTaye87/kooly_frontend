// TODO Implement this library.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:koooly_app/src/cubit/models/cart_items.dart';

class CartStorage {
  static const _key = 'cart';

  /// Save cart to local storage
  static Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }

  /// Load cart from local storage
  static Future<List<CartItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    final List<CartItem> result = [];

    for (final entry in raw) {
      try {
        final data = jsonDecode(entry);
        result.add(CartItem.fromJson(Map<String, dynamic>.from(data)));
      } catch (e) {
        debugPrint("Error decoding cart item: $e");
      }
    }

    return result;
  }

  /// Clear cart from local storage
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
