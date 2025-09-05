import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'dart:io';
// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:koooly_app/src/cubit/models/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koooly_app/src/shared/constants.dart';

class SellerScreen extends StatefulWidget {
  final String token;
  final String? sellerId;
  final List<String> categories;
  const SellerScreen(
      {required this.token,
      required this.categories,
      required this.sellerId,
      super.key});

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  List<Product> products = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingProducts = false;
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  ));
  bool uploadComplete = false;

  Future<int?> getProducts() async {
    print(
        "sellerIduuu: http://$kPrimaryBaseUrl/api/products/${widget.sellerId}");
    if (_isLoadingProducts || _currentPage > _totalPages) return 200;
    setState(() {
      _isLoadingProducts = true;
    });
    try {
      final response = await dio.get(
          "http://$kPrimaryBaseUrl/api/products/seller/${widget.sellerId}?page=$_currentPage",
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "authorization": "Bearer ${widget.token}"
            },
          ));
      if (response.statusCode == 200) {
        List<Product> prods = [];
        for (var element in response.data['data']) {
          prods.add(Product.fromJson(element));
        }
        setState(() {
          products.addAll(prods);
          _currentPage =
              (response.data["pagination"]["currentPage"] as int) + 1;
          _totalPages = response.data["pagination"]["totalPages"] as int;
          _isLoadingProducts = false;
        });
        return 200;
      } else {
        setState(() {
          _isLoadingProducts = false;
        });
        return response.statusCode;
      }
    } on DioException catch (e) {
      if (mounted) debugPrint("product get error: $e");
      setState(() {
        _isLoadingProducts = false;
      });
      return 0;
    } catch (e) {
      debugPrint("product get error: $e");
      setState(() {
        _isLoadingProducts = false;
      });
    }
    return 0;
  }

  Future<int?> buyProduct(String productId) async {
    try {
      final tobed = {"productId": productId, "quantity": 1};
      final response =
          await dio.post("http://$kPrimaryBaseUrl/api/products/buyproduct",
              options: Options(
                headers: {
                  "Content-Type": "application/json",
                  "authorization": "Bearer ${widget.token}"
                },
              ),
              data: jsonEncode(tobed));
      return response.statusCode;
    } on DioException catch (e) {
      if (mounted) debugPrint("product get error: $e");
      setState(() {
        _isLoadingProducts = false;
      });
      return 0;
    } catch (e) {
      debugPrint("product get error: $e");
      setState(() {
        _isLoadingProducts = false;
      });
    }
    return 0;
  }

  Future<int?> uploadProduct(Product product) async {
    debugPrint("uploadProduct: ${jsonEncode(product.toJson())}");

    try {
      // Convert imageUrl to MultipartFile
      MultipartFile? imageFile;
      if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
        final file = File(product.imageUrl!);
        imageFile = await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last);
      }

      // Create FormData object
      final formData = FormData.fromMap({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'stockQuantity': product.stockQuantity,
        'category': product.category,
        'status': product.status.toString().split('.').last,
        'imageUrl': imageFile, // Add the image file here
      });

      // Send the request with FormData
      final response = await dio.post(
        "http://$kPrimaryBaseUrl/api/products",
        options: Options(
          headers: {"authorization": "Bearer ${widget.token}"},
        ),
        data: formData,
      );

      debugPrint(
          "responseuploadprod: ${response.statusCode}: ${response.data}");
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;
        final List<dynamic> responseList =
            responseData is List ? responseData : [responseData];
        List<Product> prods =
            responseList.map((e) => Product.fromJson(e)).toList();
        setState(() {
          products = prods;
        });
        return 201;
      } else {
        return response.statusCode;
      }
    } catch (e) {
      debugPrint("product upload error: $e");
      return 0;
    }
  }

  Future<int?> editProduct(
      Map<String, dynamic> editData, String productId, String? imageUrl) async {
    MultipartFile? imageFile;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final file = File(imageUrl);
      imageFile = await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last);
    }

    final formData = FormData.fromMap({
      'name': editData['name'],
      'description': editData['description'],
      'price': editData['price'],
      'stockQuantity': editData['stockQuantity'],
      'category': editData['category'],
      'status': editData['status'],
      'imageUrl': imageFile
    });

    try {
      final response =
          await dio.put("http://$kPrimaryBaseUrl/api/products/$productId",
              options: Options(
                headers: {
                  "Content-Type": "application/json",
                  "authorization": "Bearer ${widget.token}"
                  // "authorization": "Bearer ${widget.user.token}"
                },
              ),
              data: formData);

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {});
        }
        return 200;
      } else {
        return response.statusCode;
      }
    } on DioException catch (e) {
      if (mounted) {
        debugPrint("product get error: $e");
        return 0;
      }
    } catch (e) {
      debugPrint("product get error: $e");
    }
    return 0;
  }

  Map<String, dynamic> editProd = {};

  @override
  void initState() {
    getProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: kPrimaryColor,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                final formKey = GlobalKey<FormState>();
                String name = '';
                String imageUrl = '';
                double price = 0.0;
                int stockQuantity = 0;
                ProductStatus status = ProductStatus.available;
                String categoryUpload = 'all';
                String description = '';

                return StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return AlertDialog(
                      title: const Text('Upload New Product'),
                      content: Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final ImagePicker picker = ImagePicker();
                                      final XFile? image =
                                          await picker.pickImage(
                                              source: ImageSource.gallery);
                                      // debugPrint("iamge: ${image?.path}");
                                      if (image != null) {
                                        setStateDialog(() {
                                          imageUrl = image.path;
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.image),
                                    label: const Text('Upload Image'),
                                  ),
                                  if (imageUrl.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Selected file: ${imageUrl.split('/').last}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Product Name'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a product name';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  name = value!;
                                },
                              ),
                              TextFormField(
                                decoration:
                                    const InputDecoration(labelText: 'Price'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a price';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  price = double.parse(value!);
                                },
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Description'),
                                keyboardType: TextInputType.multiline,
                                onSaved: (value) {
                                  description = value ?? '';
                                },
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Stock Quantity'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter stock quantity';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  stockQuantity = int.parse(value!);
                                },
                              ),
                              DropdownButtonFormField<ProductStatus>(
                                decoration:
                                    const InputDecoration(labelText: 'Status'),
                                value: status,
                                items: ProductStatus.values
                                    .map((ProductStatus status) {
                                  return DropdownMenuItem<ProductStatus>(
                                    value: status,
                                    child:
                                        Text(status.toString().split('.').last),
                                  );
                                }).toList(),
                                onChanged: (ProductStatus? newValue) {
                                  status = newValue!;
                                },
                              ),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                    labelText: 'Category'),
                                value: categoryUpload,
                                items: widget.categories.map((String category) {
                                  return DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  categoryUpload = newValue!;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        uploadComplete
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: kPrimaryColor,
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate() &&
                                      !uploadComplete) {
                                    formKey.currentState!.save();
                                    setStateDialog(() {
                                      uploadComplete = true;
                                    });
                                    final newProduct = Product(
                                        name: name,
                                        imageUrl: imageUrl,
                                        price: price,
                                        stockQuantity: stockQuantity,
                                        status: status,
                                        category: categoryUpload,
                                        description: description);
                                    final resUp =
                                        await uploadProduct(newProduct);
                                    if (resUp == 201 && context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Product uploaded'),
                                        ),
                                      );
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Failed to upload product'),
                                          ),
                                        );
                                      }
                                    }
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  }
                                },
                                child: const Text('Upload'),
                              ),
                      ],
                    );
                  },
                );
              },
            );
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          )),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text('No products uploaded yet.'))
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: SizedBox(
                              width: 50,
                              child: CachedNetworkImage(
                                imageUrl:
                                    "http://$kPrimaryBaseUrl/${product.imageUrl}",
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.broken_image, size: 50),
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              product.name,
                              style: TextStyle(
                                  fontSize: size.width > 1000
                                      ? 0.002 * size.width * 7.7
                                      : 0.002 * size.width * 16,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ETB ${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: size.width > 1000
                                            ? 0.002 * size.width * 6
                                            : 0.002 * size.width * 10,
                                        overflow: TextOverflow.ellipsis)),
                                Text('Stock: ${product.stockQuantity}',
                                    style: TextStyle(
                                        fontSize: size.width > 1000
                                            ? 0.002 * size.width * 6
                                            : 0.002 * size.width * 10,
                                        overflow: TextOverflow.ellipsis)),
                                Text(
                                    'Status: ${product.status.toString().split('.').last}',
                                    style: TextStyle(
                                        fontSize: size.width > 1000
                                            ? 0.002 * size.width * 6
                                            : 0.002 * size.width * 10,
                                        overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              debugPrint("clicked: ${product.id}");
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  final formKey = GlobalKey<FormState>();
                                  String name = product.name;
                                  String? imageUrl = product.imageUrl;
                                  num price = product.price;
                                  num stockQuantity = product.stockQuantity;
                                  ProductStatus status = product.status;

                                  return StatefulBuilder(
                                    builder: (context, setStateDialog) {
                                      return AlertDialog(
                                        title: const Text('Edit Product'),
                                        content: Form(
                                          key: formKey,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Column(
                                                  children: [
                                                    ElevatedButton.icon(
                                                      onPressed: () async {
                                                        final ImagePicker
                                                            picker =
                                                            ImagePicker();
                                                        final XFile? image =
                                                            await picker.pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .gallery);
                                                        if (image != null) {
                                                          setStateDialog(() {
                                                            imageUrl =
                                                                image.path;
                                                          });
                                                        }
                                                      },
                                                      icon: const Icon(
                                                          Icons.image),
                                                      label: const Text(
                                                          'Upload Image'),
                                                    ),
                                                    if (imageUrl != null &&
                                                        imageUrl!.isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8.0),
                                                        child: Text(
                                                          'Selected file: ${imageUrl!.split('/').last}',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                TextFormField(
                                                  initialValue: name,
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText:
                                                              'Product Name'),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter a product name';
                                                    }
                                                    return null;
                                                  },
                                                  onSaved: (value) {
                                                    name = value!;
                                                  },
                                                ),
                                                TextFormField(
                                                  initialValue:
                                                      price.toString(),
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText: 'Price'),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter a price';
                                                    }
                                                    return null;
                                                  },
                                                  onSaved: (value) {
                                                    price =
                                                        double.parse(value!);
                                                  },
                                                ),
                                                TextFormField(
                                                  initialValue:
                                                      stockQuantity.toString(),
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText:
                                                              'Stock Quantity'),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter stock quantity';
                                                    }
                                                    return null;
                                                  },
                                                  onSaved: (value) {
                                                    stockQuantity =
                                                        int.parse(value!);
                                                  },
                                                ),
                                                DropdownButtonFormField<
                                                    ProductStatus>(
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText: 'Status'),
                                                  value: status,
                                                  items: ProductStatus.values
                                                      .map((ProductStatus
                                                          status) {
                                                    return DropdownMenuItem<
                                                        ProductStatus>(
                                                      value: status,
                                                      child: Text(status
                                                          .toString()
                                                          .split('.')
                                                          .last),
                                                    );
                                                  }).toList(),
                                                  onChanged: (ProductStatus?
                                                      newValue) {
                                                    status = newValue!;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              final shouldDelete =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Confirm Delete'),
                                                    content: const Text(
                                                      'Are you sure you want to delete this product?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true),
                                                        child: const Text(
                                                            'Delete'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                              if (shouldDelete == true) {
                                                final delresp =
                                                    await _deleteProduct(
                                                        product.id!,
                                                        widget.token);
                                                if (delresp == 200 ||
                                                    delresp == 201) {
                                                  if (mounted &&
                                                      context.mounted) {
                                                    Navigator.push(
                                                      context,
                                                      PageRouteBuilder(
                                                        pageBuilder: (context,
                                                                animation,
                                                                secondaryAnimation) =>
                                                            SellerScreen(
                                                                token: widget
                                                                    .token,
                                                                categories: widget
                                                                    .categories,
                                                                sellerId: widget
                                                                    .sellerId),
                                                        transitionDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    150),
                                                        transitionsBuilder:
                                                            (context,
                                                                animation,
                                                                secondaryAnimation,
                                                                child) {
                                                          return FadeTransition(
                                                            opacity: animation,
                                                            child: child,
                                                          );
                                                        },
                                                      ),
                                                    );
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Product deleted'),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                            child: const Text(
                                              'Delete',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                formKey.currentState!.save();
                                                await editProduct({
                                                  'name': name,
                                                  'price': price,
                                                  'imageUrl': imageUrl,
                                                  'stockQuantity':
                                                      stockQuantity,
                                                  'status': status.name,
                                                  'category': product.category,
                                                }, product.id!, imageUrl);
                                                if (context.mounted) {
                                                  Navigator.of(context).pop();
                                                }
                                              }
                                            },
                                            child: const Text('Save'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_currentPage <= _totalPages)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox(
                  width: size.width / 3,
                  child: ElevatedButton(
                    onPressed: () {
                      getProducts();
                    },
                    child: _isLoadingProducts
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Center(
                            child: Text(
                              "Load More",
                              style: TextStyle(color: kPrimaryColor),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<int?> _deleteProduct(String productId, String token) async {
    debugPrint("deleteProduct: $productId");
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));
      final response = await dio.delete(
        "http://$kPrimaryBaseUrl/api/products/$productId",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $token",
            // "authorization": "Bearer ${widget.user.token}"
          },
        ),
      );
      print("deleteProduct: ${response.statusCode} : ${response.data}");
      if (mounted && context.mounted) {
        setState(() {});
      }
      return 200;
    } on DioException catch (e) {
      if (mounted) {
        debugPrint("product get error: $e");
        return 0;
      }
    } catch (e) {
      debugPrint("product get error: $e");
    }
    return 0;
  }
}
