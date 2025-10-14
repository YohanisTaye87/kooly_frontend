// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:koooly_app/src/components/rounded_button.dart';
// import 'package:koooly_app/src/cubit/models/product.dart';
// import 'package:koooly_app/src/cubit/user_cubit.dart';
// import 'package:koooly_app/src/cubit/user_state.dart';
// import 'package:koooly_app/src/shared/constants.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:koooly_app/src/views/home/seller_screen.dart'; // Added cached image support

// class MarketplacePage extends StatefulWidget {
//   const MarketplacePage({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _MarketplacePageState createState() => _MarketplacePageState();
// }

// class _MarketplacePageState extends State<MarketplacePage> {
//   List<String> categories = [];
//   List<Product> products = [];
//   List<Product> filteredProducts = [];
//   String? sellerId;
//   String? token;
//   String? roleS;
//   final dio = Dio();
//   String _selectedCategory = "all";
//   String _searchQuery = "";
//   int _currentPage = 1;
//   int _totalPages = 1;
//   bool _isLoadingProducts = false;
//   bool buyProductLoading = false;

//   Future<int?> getCategories() async {
//     try {
//       final response = await dio.get(
//         "http://$kPrimaryBaseUrl/api/category",
//         options: Options(
//           headers: {
//             "Content-Type": "application/json",
//             "authorization": "Bearer $token",
//           },
//         ),
//       );
//       if (response.statusCode == 200) {
//         List<String> cats = [];
//         for (var element in response.data) {
//           cats.add(element['name']);
//         }
//         cats.sort((a, b) => a.compareTo(b));
//         if (mounted && context.mounted) {
//           setState(() {
//             categories = cats;
//           });
//         }
//         return 200;
//       } else {
//         return response.statusCode;
//       }
//     } on DioException catch (e) {
//       if (mounted) {
//         debugPrint("product category get error: $e");
//         return 0;
//       }
//     } catch (e) {
//       debugPrint("product category get error: $e");
//     }
//     return 0;
//   }

//   Future<int?> getProducts() async {
//     if (_isLoadingProducts || _currentPage > _totalPages) return 200;
//     if (mounted && context.mounted) {
//       setState(() {
//         _isLoadingProducts = true;
//       });
//     }
//     final response = await dio.get(
//       "http://$kPrimaryBaseUrl/api/products?page=$_currentPage",
//       options: Options(
//         headers: {
//           "Content-Type": "application/json",
//           "authorization": "Bearer $token",
//         },
//       ),
//     );
//     debugPrint("responseSellerp: ${response.statusCode}:  ${response.data}");
//     if (response.statusCode == 200) {
//       List<Product> prods = [];
//       for (var element in response.data["data"]) {
//         prods.add(Product.fromJson(element));
//       }
//       if (mounted && context.mounted) {
//         setState(() {
//           products.addAll(prods);
//           // Assume pagination map has "currentPage" and "totalPages"
//           _currentPage =
//               (response.data["pagination"]["currentPage"] as int) + 1;
//           _totalPages = response.data["pagination"]["totalPages"] as int;
//           _filterProducts();
//           _isLoadingProducts = false;
//         });
//       }
//       return 200;
//     } else {
//       if (mounted && context.mounted) {
//         setState(() {
//           _isLoadingProducts = false;
//         });
//       }
//       return response.statusCode;
//     }
//   }

//   void _filterProducts() {
//     if (mounted) {
//       setState(() {
//         filteredProducts = products.where((product) {
//           final matchesCategory = _selectedCategory.toLowerCase() == "all" ||
//               product.category.toLowerCase() == _selectedCategory.toLowerCase();
//           final matchesSearch = _searchQuery.isEmpty ||
//               product.name.toLowerCase().contains(_searchQuery.toLowerCase());
//           return matchesCategory && matchesSearch;
//         }).toList();
//       });
//     }
//   }

//   @override
//   void initState() {
//     final userCubit = context.read<UserCubit>();
//     final currentState = userCubit.state;
//     if (currentState is UserLoaded && mounted) {
//       setState(() {
//         token = currentState.user.token;
//         roleS = currentState.user.role?.name;
//         sellerId = currentState.user.id;
//       });
//     }
//     getCategories();
//     getProducts().then((_) {
//       _filterProducts();
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final size = MediaQuery.sizeOf(context);
//     print("sellerCheck: $roleS");
//     return Scaffold(
//       floatingActionButton: roleS == 'sellers'
//           ? FloatingActionButton(
//               backgroundColor: kPrimaryColor,
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   PageRouteBuilder(
//                     pageBuilder: (context, animation, secondaryAnimation) =>
//                         SellerScreen(
//                       token: token ?? '',
//                       categories: categories,
//                       sellerId: sellerId,
//                     ),
//                     transitionDuration: const Duration(milliseconds: 150),
//                     transitionsBuilder:
//                         (context, animation, secondaryAnimation, child) {
//                       return FadeTransition(
//                         opacity: animation,
//                         child: child,
//                       );
//                     },
//                   ),
//                 );
//               },
//               child: const Icon(Icons.shop_two, color: Colors.white),
//             )
//           : null,
//       appBar: AppBar(
//         title: const Text("Marketplace"),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               onChanged: (value) {
//                 _searchQuery = value;
//                 _filterProducts();
//               },
//               decoration: InputDecoration(
//                 hintText: "Search products...",
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 50,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: categories.length,
//                 separatorBuilder: (context, index) => const SizedBox(width: 8),
//                 itemBuilder: (context, index) {
//                   final category = categories[index];
//                   return ChoiceChip(
//                     label: Text(category),
//                     selected: _selectedCategory == category,
//                     onSelected: (isSelected) {
//                       _selectedCategory = isSelected ? category : "all";
//                       _filterProducts();
//                     },
//                   );
//                 },
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Expanded(
//             child: filteredProducts.isEmpty
//                 ? const Center(child: Text("No products found"))
//                 : Column(
//                     children: [
//                       Expanded(
//                         child: GridView.builder(
//                           padding: const EdgeInsets.all(8.0),
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 8,
//                             mainAxisSpacing: 8,
//                           ),
//                           itemCount: filteredProducts.length,
//                           itemBuilder: (context, index) {
//                             final product = filteredProducts[index];

//                             return GestureDetector(
//                               onTap: () {
//                                 _showProductDetails(
//                                   context,
//                                   product,
//                                   MediaQuery.of(context).size,
//                                 );
//                               },
//                               child: Card(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.stretch,
//                                   children: [
//                                     Expanded(
//                                       child: ClipRRect(
//                                         borderRadius:
//                                             const BorderRadius.vertical(
//                                           top: Radius.circular(12),
//                                         ),
//                                         child: CachedNetworkImage(
//                                           imageUrl:
//                                               "http://$kPrimaryBaseUrl/${product.imageUrl}",
//                                           placeholder: (context, url) =>
//                                               const Center(
//                                             child: CircularProgressIndicator(),
//                                           ),
//                                           errorWidget: (context, url, error) =>
//                                               const Icon(
//                                             Icons.broken_image,
//                                             size: 50,
//                                           ),
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             product.name,
//                                             style: const TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 16,
//                                             ),
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                           const SizedBox(height: 4),
//                                           Text(
//                                             " ETB ${product.price.toStringAsFixed(2)}",
//                                             style: const TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 14,
//                                               color: Colors.green,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       if (_currentPage <= _totalPages)
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: ElevatedButton(
//                             onPressed: () {
//                               getProducts();
//                             },
//                             child: _isLoadingProducts
//                                 ? const SizedBox(
//                                     width: 20,
//                                     height: 20,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       color: Colors.white,
//                                     ),
//                                   )
//                                 : const Text("Load More"),
//                           ),
//                         ),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<int?> buyProduct(String productId) async {
//     setState(() {
//       buyProductLoading = true;
//     });
//     try {
//       final tobed = {"productId": productId, "quantity": 1};
//       print("tobuyprod: $tobed");
//       final response =
//           await dio.post("http://$kPrimaryBaseUrl/api/products/buyproduct",
//               options: Options(
//                 headers: {
//                   "Content-Type": "application/json",
//                   "authorization": "Bearer $token"
//                 },
//               ),
//               data: jsonEncode(tobed));
//       print("tobuyprod77: ${response.statusCode} : ${response.data}");
//       if (mounted &&
//           (response.statusCode == 200 || response.statusCode == 201)) {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               backgroundColor: Colors.green,
//               content: Text(
//                   "Seller notified successfully, please wait for confirmation")),
//         );
//       } else if (mounted && response.statusCode == 230) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content:
//                   Text("Product is out of stock... Seller has been notified")),
//         );
//       } else if (mounted && response.statusCode.toString()[0] == '2') {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Failed to buy product"),
//           ),
//         );
//       }
//       return response.statusCode;
//     } on DioException catch (e) {
//       if (mounted) debugPrint("product get error: $e");
//       setState(() {
//         _isLoadingProducts = false;
//         buyProductLoading = false;
//       });
//       return 0;
//     } catch (e) {
//       debugPrint("product get error: $e");
//       if (mounted) {
//         setState(() {
//           _isLoadingProducts = false;
//           buyProductLoading = false;
//         });
//       }
//     }
//     return 0;
//   }

//   void _showProductDetails(BuildContext context, Product product, Size size) {
//     setState(() {
//       buyProductLoading = false;
//     });
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(builder: (context, setStateDialog) {
//           return AlertDialog(
//             title: Text(product.name),
//             content: buyProductLoading
//                 ? SizedBox(
//                     height: size.height / 7,
//                     width: size.width / 3,
//                     child: const Center(
//                       child: CircularProgressIndicator(
//                         color: kPrimaryColor,
//                       ),
//                     ),
//                   )
//                 : SingleChildScrollView(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         CachedNetworkImage(
//                           imageUrl:
//                               "http://$kPrimaryBaseUrl/${product.imageUrl}",
//                           width: size.width / 2,
//                           height: size.height / 4,
//                           placeholder: (context, url) =>
//                               const Center(child: CircularProgressIndicator()),
//                           errorWidget: (context, url, error) => const Center(
//                             child: Icon(
//                               Icons.broken_image,
//                               size: 100,
//                               color: Colors.black,
//                             ),
//                           ),
//                           fit: BoxFit.cover,
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           "Price: \$${product.price.toStringAsFixed(2)}",
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           "Seller Contact: ${product.seller?['name']}",
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                         const SizedBox(height: 10),
//                         Visibility(
//                           visible: product.seller?['email'] != null,
//                           child: Text(
//                             "Email: ${product.seller?['email']}",
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                         Visibility(
//                             visible: product.seller?['email'] != null,
//                             child: const SizedBox(height: 10)),
//                         Visibility(
//                           visible: product.seller?['phone'] != null,
//                           child: Text(
//                             "Phone: ${product.seller?['phone'] ?? 'N/A'}",
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                         Visibility(
//                             visible: product.seller?['phone'] != null,
//                             child: const SizedBox(height: 10)),
//                         Visibility(
//                           visible: product.description != null,
//                           child: Text(
//                             "${product.description}",
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                         RoundedButton(
//                             text: "Buy",
//                             onTap: () async {
//                               if (product.id != null) {
//                                 setStateDialog(() {
//                                   buyProductLoading = true;
//                                 });
//                                 await buyProduct(product.id!);
//                               }
//                             },
//                             width: size.width / 3,
//                             height: size.width / 9)
//                       ],
//                     ),
//                   ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text("Close"),
//               ),
//             ],
//           );
//         });
//       },
//     );
//   }
// }
