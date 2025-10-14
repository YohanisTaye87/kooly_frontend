import 'package:flutter/material.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:koooly_app/providers/cart_providers.dart';
import 'package:koooly_app/widgets/cart_item_tile.dart';

class MarketCartTab extends StatefulWidget {
  const MarketCartTab({super.key});

  @override
  State<MarketCartTab> createState() => _MarketCartTabState();
}

class _MarketCartTabState extends State<MarketCartTab> {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: primaryBackground,
      body: cart.items.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (_, i) => CartItemTile(item: cart.items[i]),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: const Border(top: BorderSide(color: Colors.grey)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Subtotal: ETB ${cart.subtotal.toStringAsFixed(2)}"),
                      if (cart.totalDiscount > 0)
                        Text(
                            "Discount: -ETB ${cart.totalDiscount.toStringAsFixed(2)}"),
                      const Divider(),
                      Text(
                        "Total: ETB ${cart.total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to checkout flow
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 140),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Confirm Order",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
