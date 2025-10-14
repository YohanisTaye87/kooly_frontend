import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koooly_app/providers/cart_providers.dart';
import 'package:koooly_app/src/cubit/models/product.dart';
import 'package:koooly_app/src/cubit/user_cubit.dart';
import 'package:koooly_app/src/cubit/user_state.dart';
import 'package:koooly_app/src/shared/constants.dart';
import 'package:koooly_app/src/views/market/product_detail_page.dart';
import 'package:koooly_app/utils/image_utils.dart';
import 'package:shimmer/shimmer.dart';

class Shop {
  final String name;
  final String imageUrl;
  final String id;

  Shop({required this.name, required this.imageUrl, required this.id});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}

class MarketHomeTab extends StatefulWidget {
  final bool showSearchBar;

  const MarketHomeTab({super.key, required this.showSearchBar});

  @override
  _MarketplacePageState createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketHomeTab> {
  final dio = Dio();

  // Auth / role
  String? sellerId;
  String? token;
  String? roleS;

  // Banner
  final PageController _bannerController =
      PageController(viewportFraction: 0.85);
  Timer? _bannerTimer;
  int _currentBanner = 0;
  List<String> bannerImages = [];

  // Shops
  List<Shop> shops = [];

  // Categories & products
  List<String> categories = [];
  List<Product> products = [];
  List<Product> filteredProducts = [];

  // Popular products
  List<Product> popularProducts = [];

  // Category icons
  final Map<String, IconData> categoryIcons = {
    "chair": Icons.chair_alt_outlined,
    "locker": Icons.kitchen,
    "table": Icons.table_bar,
    "sofa": Icons.weekend,
    "cabinates": Icons.kitchen_sharp,
  };

  // UI state
  String _selectedCategory = "all";
  String _searchQuery = "";
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingProducts = false; // start false so first fetch runs
  bool buyProductLoading = false;

  @override
  void initState() {
    super.initState();

    final userCubit = context.read<UserCubit>();
    final currentState = userCubit.state;
    if (currentState is UserLoaded) {
      token = currentState.user.token;
      roleS = currentState.user.role?.name;
      sellerId = currentState.user.id;
    }

    getBanners();
    // remove this and use getShops(); after backend is done.
    _setMockShopsAssets();
    // await getShops();
    getCategories();
    getProducts();

    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_bannerController.hasClients || bannerImages.isEmpty) return;
      final nextPage = (_currentBanner + 1) % bannerImages.length;
      _bannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      if (mounted) setState(() => _currentBanner = nextPage);
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  // ---------- Data fetchers ----------

  Future<void> getBanners() async {
    try {
      final response = await dio.get(
        "http://$kPrimaryBaseUrl/api/banners",
        options: Options(headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200 && response.data is List && mounted) {
        final banners = List<String>.from(
          response.data
              .map(
                  (e) => e is Map<String, dynamic> ? (e['imageUrl'] ?? '') : '')
              .where((url) => url is String && url.isNotEmpty),
        );
        setState(() => bannerImages = banners);
      } else {
        _setMockBanners();
      }
    } catch (e) {
      debugPrint("Banner fetch error: $e");
      _setMockBanners();
    }
  }

  void _setMockBanners() {
    if (!mounted) return;
    setState(() => bannerImages = [
          "http://$kPrimaryBaseUrl/assets/banner1.png",
          "http://$kPrimaryBaseUrl/assets/banner2.png",
          "http://$kPrimaryBaseUrl/assets/banner3.png",
        ]);
  }

  void _setMockShopsAssets() {
    setState(() => shops = [
          Shop(
              name: "Wub Futniture",
              imageUrl: 'assets/shops/shop1.png',
              id: "1"),
          Shop(name: "SAR Studio", imageUrl: 'assets/shops/shop2.png', id: "2"),
          Shop(name: "Bambis", imageUrl: 'assets/shops/shop3.png', id: "3"),
          Shop(name: "All Mart", imageUrl: 'assets/shops/shop4.png', id: "4"),
          Shop(
              name: " Shewa Supermarket",
              imageUrl: 'assets/shops/shop5.png',
              id: "5"),
          Shop(name: " Gebeya", imageUrl: 'assets/shops/shop6.png', id: "6"),
        ]);
  }

  Future<void> getShops() async {
    try {
      final response = await dio.get(
        "http://$kPrimaryBaseUrl/api/shops",
        options: Options(headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200 && response.data is List && mounted) {
        final loadedShops = List<Shop>.from(
          response.data
              .whereType<Map<String, dynamic>>()
              .map((e) => Shop.fromJson(e)),
        );
        setState(() => shops = loadedShops);
      }
    } catch (e) {
      debugPrint("Shop fetch error: $e");
      // No fallback needed; UI is guarded by shops.isNotEmpty
    }
  }

  Future<int?> getCategories() async {
    try {
      final response = await dio.get(
        "http://$kPrimaryBaseUrl/api/category",
        options: Options(headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200 && mounted) {
        final raw = response.data;
        final names = <String>[];

        for (final e in (raw is List ? raw : [])) {
          final name = (e is Map && e['name'] is String)
              ? e['name'].toString().trim()
              : null;
          if (name != null && name.isNotEmpty) names.add(name);
        }

        // Add fallback categories if too few
        if (names.length < 3) {
          names.addAll(["Cabinetes", "Table", "Chair", "Locker"]);
        }

        names.removeWhere((e) => e.toLowerCase() == "all");
        names.sort();
        names.insert(0, "All");

        setState(() => categories = names);
        return 200;
      }

      return response.statusCode;
    } catch (e) {
      debugPrint("Category fetch error: $e");
      if (mounted) {
        setState(
            () => categories = ["All", "Sofa", "Chair", "Locker", "Cabinates"]);
      }
      return 0;
    }
  }

  Future<int?> getProducts() async {
    if (_isLoadingProducts || _currentPage > _totalPages) return 200;
    if (mounted) setState(() => _isLoadingProducts = true);

    try {
      final response = await dio.get(
        "http://$kPrimaryBaseUrl/api/products?page=$_currentPage",
        options: Options(headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200) {
        final list = response.data["data"];
        final prods = List<Product>.from(
          (list is List ? list : [])
              .whereType<Map<String, dynamic>>()
              .map((e) => Product.fromJson(e)),
        );

        final pagination = response.data["pagination"] ?? {};
        final current = (pagination["currentPage"] is int)
            ? pagination["currentPage"] as int
            : _currentPage;
        final total = (pagination["totalPages"] is int)
            ? pagination["totalPages"] as int
            : _totalPages;

        if (mounted) {
          setState(() {
            products.addAll(prods);
            _currentPage = current + 1;
            _totalPages = total;
            _mockPopularProducts();
            _filterProducts();

            /// until backend supports it
            _filterPopularProducts();
            _isLoadingProducts = false;
          });
        }
        return 200;
      } else {
        if (mounted) setState(() => _isLoadingProducts = false);
        return response.statusCode;
      }
    } catch (e) {
      debugPrint("Product fetch error: $e");
      if (mounted) setState(() => _isLoadingProducts = false);
      return 0;
    }
  }

  void _mockPopularProducts() {
    for (var i = 0; i < products.length; i++) {
      if (products[i].name.toLowerCase().contains("sofa") || i % 3 == 0) {
        products[i] = Product(
          name: products[i].name,
          imageUrl: products[i].imageUrl,
          price: products[i].price,
          category: products[i].category,
          seller: products[i].seller,
          description: products[i].description,
          id: products[i].id,
          isPopular: true,
        );
      }
    }
    _filterPopularProducts();
  }

  // ---------- Filtering ----------

  void _filterProducts() {
    if (!mounted) return;

    final query = _searchQuery.trim().toLowerCase();
    final selectedCategory = _selectedCategory.trim().toLowerCase();

    setState(() {
      filteredProducts = products.where((product) {
        final matchesCategory = selectedCategory == "all" ||
            product.category.toLowerCase() == selectedCategory;

        final matchesSearch = query.isEmpty ||
            product.name.toLowerCase().contains(query) ||
            (product.description ?? '').toLowerCase().contains(query);

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _filterPopularProducts() {
    popularProducts = products.where((p) => p.isPopular == true).toList();
  }

  // ---------- Actions ----------

  Future<int?> buyProduct(String productId) async {
    setState(() => buyProductLoading = true);
    try {
      final response = await dio.post(
        "http://$kPrimaryBaseUrl/api/products/buyproduct",
        options: Options(headers: {
          "Content-Type": "application/json",
          "authorization": "Bearer $token"
        }),
        data: jsonEncode({"productId": productId, "quantity": 1}),
      );
      if (!mounted) return response.statusCode;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
              "Seller notified successfully, please wait for confirmation"),
        ));
      } else if (response.statusCode == 230) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Product is out of stock... Seller has been notified"),
        ));
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to buy product"),
        ));
      }
      setState(() => buyProductLoading = false);
      return response.statusCode;
    } catch (e) {
      debugPrint("Buy product error: $e");
      if (mounted) setState(() => buyProductLoading = false);
      return 0;
    }
  }

  // ---------- Reusable shimmers ----------

  Widget _bannerShimmer() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: 2,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _shopShimmer() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            children: [
              Container(
                width: 75,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 60,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _popularShimmer() {
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gridShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 12,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 12,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Optional card builder (kept for reuse) ----------

  Widget buildProductCard(Product product, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: "http://$kPrimaryBaseUrl/${product.imageUrl}",
                      placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 50),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  if (product.isPopular)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text("🔥 Popular",
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text("ETB ${product.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final bool isLoadingPopularSection =
        _selectedCategory.toLowerCase() == "all" &&
            _isLoadingProducts &&
            popularProducts.isEmpty;
    final bool isLoadingProductsSection =
        _isLoadingProducts && filteredProducts.isEmpty;

    return Scaffold(
      backgroundColor: primaryBackground,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showSearchBar)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      textSelectionTheme: const TextSelectionThemeData(
                        cursorColor: kPrimaryColor,
                        selectionColor: kPrimaryColor,
                        selectionHandleColor: kPrimaryColor,
                      ),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        print("Search input: $value");
                        _searchQuery = value;
                        setState(() => _selectedCategory = "All");
                        _filterProducts();
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: primaryBackground,
                        hintText: "Search products...",
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: kPrimaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      cursorColor: kPrimaryColor,
                    ),
                  ),
                ),

              const SizedBox(height: 15),

              // Banner
              if (bannerImages.isEmpty) ...[
                _bannerShimmer(),
              ] else ...[
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: _bannerController,
                    itemCount: bannerImages.length,
                    onPageChanged: (index) =>
                        setState(() => _currentBanner = index),
                    itemBuilder: (context, index) {
                      final imageUrl = bannerImages[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: size.width * 0.8,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(color: Colors.white),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.broken_image, size: 40),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(bannerImages.length, (index) {
                    final isActive = index == _currentBanner;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 10 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? kPrimaryColor : Colors.grey,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ],

              const SizedBox(height: 10),

              // Shops (below banner)
              if (shops.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Text("Shops",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                _shopShimmer(),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Text("Shops",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: shops.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final shop = shops[index];
                      return GestureDetector(
                        onTap: () {
                          // TODO: Navigate to shop page or filter products by shop
                        },
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: shop.imageUrl,
                                width: 75,
                                height: 70,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                      width: 75,
                                      height: 70,
                                      color: Colors.white),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 75,
                                  height: 70,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.store, size: 30),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 70,
                              child: Text(
                                shop.name,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 15),

              // Categories
              if (categories.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    "Category",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = _selectedCategory.toLowerCase() ==
                          category.toLowerCase();
                      final icon = categoryIcons[category.toLowerCase()];

                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected && icon != null) ...[
                              Icon(icon, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                            ],
                            Text(category),
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: kPrimaryColor,
                        backgroundColor: primaryBackground,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : "All";
                            _filterProducts();
                          });
                        },
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Popular products
              if (_selectedCategory.toLowerCase() == "all") ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Popular Products",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to full popular list or filter by isPopular
                        },
                        child: const Text(
                          "See All",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  color: primaryBackground,
                  height: 260,
                  child: isLoadingPopularSection
                      ? _popularShimmer()
                      : (popularProducts.isEmpty
                          ? Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  "No popular products yet",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                            )
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: popularProducts.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final product = popularProducts[index];
                                return SizedBox(
                                  width: 160,
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ProductDetailPage(product: product),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              height: 160,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: CachedNetworkImage(
                                                  imageUrl: buildImageUrl(
                                                      "http://$kPrimaryBaseUrl",
                                                      product.imageUrl),
                                                  fit: BoxFit.cover,
                                                  placeholder: (_, __) =>
                                                      Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey.shade300,
                                                    highlightColor:
                                                        Colors.grey.shade100,
                                                    child: Container(
                                                        color: Colors.white),
                                                  ),
                                                  errorWidget: (_, __, ___) =>
                                                      const Icon(
                                                          Icons.broken_image,
                                                          size: 30),
                                                ),
                                              ),
                                            ),

                                            // ❤️ Wishlist icon
                                            Positioned(
                                              top: 6,
                                              right: 6,
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(6),
                                                child: const Icon(
                                                    Icons.favorite_border,
                                                    size: 16,
                                                    color: Colors.grey),
                                              ),
                                            ),

                                            // 🛒 Cart icon
                                            Positioned(
                                              bottom: 6,
                                              right: 6,
                                              child: GestureDetector(
                                                onTap: () {
                                                  final cart = context
                                                      .read<CartProvider>();
                                                  cart.addToCart(product);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          "${product.name} added to cart"),
                                                      duration: const Duration(
                                                          seconds: 2),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  child: const Icon(
                                                      Icons
                                                          .shopping_bag_outlined,
                                                      size: 16,
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "ETB ${product.price.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.green),
                                        ),
                                        if ((product.description ?? '')
                                            .isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            product.description!,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )),
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 6),

              // Product grid section
              if (_selectedCategory.toLowerCase() == 'all') ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "All Products",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: _isLoadingProducts ? null : () => getProducts(),
                        child: _isLoadingProducts
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                "See More",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],

              // Product Grid
              Container(
                color: primaryBackground,
                child: isLoadingProductsSection
                    ? _gridShimmer()
                    : (filteredProducts.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: Text("No products found")),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(8.0),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (_, i) {
                              final product = filteredProducts[i];
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailPage(product: product),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: 160,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Hero(
                                              tag: product.id!,
                                              child: CachedNetworkImage(
                                                imageUrl: buildImageUrl(
                                                    "http://$kPrimaryBaseUrl",
                                                    product.imageUrl),
                                                fit: BoxFit.cover,
                                                placeholder: (_, __) =>
                                                    Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade100,
                                                  child: Container(
                                                      color: Colors.white),
                                                ),
                                                errorWidget: (_, __, ___) =>
                                                    const Icon(
                                                        Icons.broken_image,
                                                        size: 30),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // ❤️ Wishlist icon
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            child: const Icon(
                                                Icons.favorite_border,
                                                size: 16,
                                                color: Colors.grey),
                                          ),
                                        ),
                                        // 🛒 Cart icon
                                        Positioned(
                                          bottom: 6,
                                          right: 6,
                                          child: GestureDetector(
                                            onTap: () {
                                              final cart =
                                                  context.read<CartProvider>();
                                              cart.addToCart(product);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    "${product.name} added to cart"),
                                                duration:
                                                    const Duration(seconds: 2),
                                              ));
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                              ),
                                              padding: const EdgeInsets.all(6),
                                              child: const Icon(
                                                  Icons.shopping_bag_outlined,
                                                  size: 16,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(product.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text(
                                        "ETB ${product.price.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            fontSize: 13, color: Colors.green)),
                                    if ((product.description ?? '')
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(product.description!,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    ],
                                  ],
                                ),
                              );
                            })),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
