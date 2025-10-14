import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:koooly_app/providers/cart_providers.dart';
import 'package:provider/provider.dart';
import 'package:koooly_app/src/cubit/models/product.dart';
import 'package:koooly_app/src/shared/constants.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: primaryBackground,
      appBar: AppBar(
        backgroundColor: primaryBackground,
        elevation: 0,
        centerTitle: true,
        title: const Text("Product",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: product.id!,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: "http://$kPrimaryBaseUrl/${product.imageUrl}",
                      width: double.infinity,
                      height: size.height / 3,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(product.name,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone, color: Colors.green),
                      onPressed: () {
                        final phone = product.seller?['phone'];
                        if (phone != null) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Contact Seller"),
                              content: Text("Phone: $phone"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Phone number not available"),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if ((product.description ?? '').isNotEmpty)
                  Text(product.description!,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 16),
                Text("Seller: ${product.seller?['name'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: primaryBackground,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Quantity selector
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          quantity = quantity > 1 ? quantity - 1 : 1;
                        }),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$quantity', style: const TextStyle(fontSize: 16)),
                      IconButton(
                        onPressed: () => setState(() {
                          quantity++;
                        }),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text("ETB ${product.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text("Add"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      final cart = context.read<CartProvider>();
                      for (int i = 0; i < quantity; i++) {
                        cart.addToCart(product);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text("$quantity × ${product.name} added to cart"),
                        duration: const Duration(seconds: 2),
                      ));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
