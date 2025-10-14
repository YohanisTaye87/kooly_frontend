import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  double? discount;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.discount,
  });

  num get unitPrice => product.price;
  num get lineSubtotal => unitPrice * quantity;
  double get lineDiscount => (discount ?? 0.0).clamp(0, double.infinity);
  double get total => (lineSubtotal - lineDiscount).clamp(0, double.infinity);

  /// Serialize for local storage
  Map<String, dynamic> toJson() => {
        'id': product.id,
        'product': product.toJson(),
        'quantity': quantity,
        'discount': discount,
      };

  /// Deserialize from storage
  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: Product.fromJson(json['product']),
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        discount: (json['discount'] as num?)?.toDouble(),
      );
}
