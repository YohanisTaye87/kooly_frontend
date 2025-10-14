// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koooly_app/providers/cart_providers.dart';
import 'package:koooly_app/src/cubit/models/cart_items.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:koooly_app/utils/image_utils.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  const CartItemTile({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final url = buildImageUrl('http://$kPrimaryBaseUrl', item.product.imageUrl);
    final unitPrice = item.product.price.toStringAsFixed(2);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Image + Info + Delete
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: url.isEmpty
                    ? const Icon(Icons.broken_image, size: 80)
                    : Image.network(
                        url,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 80),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    if ((item.product.description ?? '').isNotEmpty)
                      Text(
                        item.product.description!,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ETB $unitPrice",
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            // Minus
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () => cart.decreaseQuantity(item),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text("${item.quantity}",
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 8),
                            // Plus
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.add,
                                    size: 18, color: Colors.white),
                                onPressed: () => cart.increaseQuantity(item),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (item.lineDiscount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Discount: -ETB ${item.lineDiscount.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => cart.removeFromCart(item.product.id ?? ''),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
