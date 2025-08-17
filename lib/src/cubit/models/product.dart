enum ProductStatus { available, outOfStock, discontinued }

class Product {
  final String? id;
  final String name;
  final String? description;
  final num price;
  final String? imageUrl;
  final num stockQuantity;
  // final String sellerId;
  final ProductStatus status;
  final String category;
  final Map<String, dynamic>? seller;
  Product(
      {this.id,
      required this.name,
      this.description,
      required this.price,
      required this.imageUrl,
      required this.stockQuantity,
      // required this.sellerId,
      required this.status,
      this.seller,
      required this.category});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['image'],
      stockQuantity: json['stockQuantity'],
      // sellerId: json['sellerId'],
      seller: json['seller'],
      category: json['category'] ?? 'all',
      status: ProductStatus.values.firstWhere(
        (e) => e.toString() == 'ProductStatus.' + json['status'],
      ),
    );
  }

  // Method to convert a Product to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'stockQuantity': stockQuantity,
      'category': category,
      'status': status.toString().split('.').last,
    };
  }
}
