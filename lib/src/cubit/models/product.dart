enum ProductStatus { available, outOfStock, discontinued }

class Product {
  final String? id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final String category;
  final Map<String, dynamic>? seller;
  final bool isPopular;

  // Optional future fields
  // final num? stockQuantity;
  // final String? sellerId;
  // final ProductStatus? status;

  Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    this.seller,
    this.isPopular = false,
    // this.stockQuantity,
    // this.sellerId,
    // this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    double parsedPrice;
    if (rawPrice is int) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is double) {
      parsedPrice = rawPrice;
    } else if (rawPrice is String) {
      parsedPrice = double.tryParse(rawPrice.replaceAll(',', '')) ?? 0.0;
    } else {
      parsedPrice = 0.0;
    }

    final img = json['imageUrl'] ?? json['imageurl'] ?? json['image'];

    return Product(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: parsedPrice,
      imageUrl: img?.toString(),
      category: json['category']?.toString() ?? 'all',
      seller: json['seller'] as Map<String, dynamic>?,
      isPopular: json['isPopular'] == true,
      // stockQuantity: json['stockQuantity'] as num?,
      // sellerId: json['sellerId']?.toString(),
      // status: _parseStatus(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description ?? '',
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isPopular': isPopular,
      'seller': seller,
      // 'stockQuantity': stockQuantity,
      // 'sellerId': sellerId,
      // 'status': status?.toString().split('.').last,
    };
  }

  // Optional: Enum parser
  static ProductStatus? _parseStatus(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'available':
          return ProductStatus.available;
        case 'outofstock':
          return ProductStatus.outOfStock;
        case 'discontinued':
          return ProductStatus.discontinued;
      }
    }
    return null;
  }
}
