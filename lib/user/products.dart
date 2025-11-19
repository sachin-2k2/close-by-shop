import 'package:close_by_shop/user/cartscreen.dart';
import 'package:close_by_shop/user/register.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

List<dynamic> products = [];
List<dynamic> filteredProducts = []; // For searched products
List<dynamic> cartItems = []; // Cart items list

class _ProductsState extends State<Products> {
  // Declare controller as instance variable, not global
  late TextEditingController _searchController;
  bool _isLoading = true;
  String _errorMessage = '';
  int _cartItemsCount = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(); // Initialize in initState
    get_products(context);
    _loadCartCount(); // Load cart count from API
  }

  Future<void> get_products(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? loginid = prefs.getInt('login_id');

      final response = await dio.get('$baseurl/Product_API/');
      print("Products API Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          products = response.data;
          filteredProducts = List.from(
            products,
          ); // Initialize filtered list with all products
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${products.length} products loaded')),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch products: ${response.statusCode}';
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to fetch products')));
      }
    } catch (e) {
      print("Error in get_products: $e");
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> Post_Cart(int productid, BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? loginid = prefs.getInt('login_id');

      if (loginid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login to add items to cart')),
        );
        return;
      }

      final response = await dio.post(
        '$baseurl/addtocart/',
        data: {'loginid': loginid, 'productid': productid},
      );

      print("Add to Cart Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh cart count after adding item
        await _loadCartCount();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product Added To Cart successfully'),
            action: SnackBarAction(
              label: 'View Cart',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product to cart')),
        );
      }
    } catch (e) {
      print("Error in Post_Cart: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  // Load cart count from API
  Future<void> _loadCartCount() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? loginid = prefs.getInt('login_id');

      if (loginid == null) {
        setState(() {
          _cartItemsCount = 0;
        });
        return;
      }

      final response = await dio.get(
        '$baseurl/fetchcart/',
        data: {'loginid': loginid},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final cartItems = responseData['cart_items'] ?? [];
          int totalCount = 0;

          // Calculate total quantity from cart items (handle numeric/string types safely)
          for (var item in cartItems) {
            final qtyValue = item['quantity'];
            int qty = 1;
            if (qtyValue is int) {
              qty = qtyValue;
            } else if (qtyValue is double) {
              qty = qtyValue.toInt();
            } else if (qtyValue is String) {
              qty = int.tryParse(qtyValue) ?? (double.tryParse(qtyValue)?.toInt() ?? 1);
            } else if (qtyValue is num) {
              qty = qtyValue.toInt();
            }
            totalCount += qty;
          }

          setState(() {
            _cartItemsCount = totalCount;
          });
        }
      }
    } catch (e) {
      print("Error loading cart count: $e");
      setState(() {
        _cartItemsCount = 0;
      });
    }
  }

  // Function to filter products based on search query
  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = List.from(products);
      } else {
        filteredProducts = products.where((product) {
          final productName =
              product['ProductName']?.toString().toLowerCase() ?? '';
          final description =
              product['description']?.toString().toLowerCase() ?? '';
          final price = product['Price']?.toString().toLowerCase() ?? '';
          final productType =
              product['ProductsType']?.toString().toLowerCase() ?? '';
          final shopName = product['shopname']?.toString().toLowerCase() ?? '';

          return productName.contains(query.toLowerCase()) ||
              description.contains(query.toLowerCase()) ||
              price.contains(query.toLowerCase()) ||
              productType.contains(query.toLowerCase()) ||
              shopName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // Function to clear search
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      filteredProducts = List.from(products);
    });
  }

  // Function to build proper image URL
  String _buildImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/150';
    }

    // If the image path already starts with http, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // If the image path starts with /media, construct the full URL
    if (imagePath.startsWith('/media')) {
      // Remove the leading slash if baseurl already has one
      String base = baseurl.endsWith('/')
          ? baseurl.substring(0, baseurl.length - 1)
          : baseurl;
      String path = imagePath.startsWith('/') ? imagePath : '/$imagePath';
      return '$base$path';
    }

    // Handle relative paths without leading slash
    if (!imagePath.startsWith('/')) {
      imagePath = '/$imagePath';
    }

    // Default case - prepend baseurl
    return '$baseurl$imagePath';
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller properly
    super.dispose();
  }

  Widget _buildProductCard(dynamic product, int index) {
    String imageUrl = _buildImageUrl(product['Img']);
    String productName =
        product['ProductName']?.toString() ?? 'Unknown Product';
    String description = product['description']?.toString() ?? 'No description';
    String price = product['Price']?.toString() ?? 'N/A';
    String productType = product['ProductsType']?.toString() ?? 'N/A';
    String shopName = product['shopname']?.toString() ?? 'Unknown Shop';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.blue.shade50],
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.blue.shade100,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade800,
                        ),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    print('Image load error: $error for URL: $url');
                    return Container(
                      color: Colors.blue.shade100,
                      child: Icon(
                        Icons.shopping_bag,
                        color: Colors.blue.shade800,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
            ),
            title: Text(
              productName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue.shade900,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                // Description
                if (description.isNotEmpty && description != 'No description')
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 8),
                // Price
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.green.shade700,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '₹$price',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                // Product Type
                if (productType != 'N/A')
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Type: $productType',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 4),
                // Shop Name
                Row(
                  children: [
                    Icon(Icons.store, size: 16, color: Colors.grey.shade600),
                    SizedBox(width: 4),
                    Text(
                      'Shop: $shopName',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _showProductDetails(product);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text('Details', style: TextStyle(fontSize: 12)),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Post_Cart(product['id'], context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 37, 130, 56),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProductDetails(dynamic product) {
    String imageUrl = _buildImageUrl(product['Img']);
    String productName =
        product['ProductName']?.toString() ?? 'Unknown Product';
    String description =
        product['description']?.toString() ?? 'No description available';
    String price = product['Price']?.toString() ?? 'N/A';
    String productType = product['ProductsType']?.toString() ?? 'N/A';
    String shopName = product['shopname']?.toString() ?? 'Unknown Shop';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.shopping_bag, color: Colors.blue.shade800),
              SizedBox(width: 8),
              Text(
                'Product Details',
                style: TextStyle(color: Colors.blue.shade800),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Image
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue.shade50,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue.shade300,
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag,
                                size: 60,
                                color: Colors.blue.shade300,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Product Name
                Text(
                  productName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                SizedBox(height: 12),
                // Details
                _buildDetailRow(Icons.description, 'Description', description),
                _buildDetailRow(Icons.attach_money, 'Price', '₹$price'),
                _buildDetailRow(Icons.category, 'Product Type', productType),
                _buildDetailRow(Icons.store, 'Shop', shopName),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Post_Cart(product['id'], context);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 37, 130, 56),
                foregroundColor: Colors.white,
              ),
              child: Text('Add to Cart'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade600),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 4),
                Text(value, style: TextStyle(color: Colors.grey.shade800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _buyProduct(dynamic product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Buying ${product['ProductName']}...'),
        duration: Duration(seconds: 2),
      ),
    );
    // Add your buy product logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(239, 255, 255, 255),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section with Cart Icon
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                height: 50,
                                width: 50,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Close By Shop Search',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Cart Icon with badge
                        Stack(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.shopping_cart,
                                color: Colors.blue.shade800,
                                size: 28,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CartScreen(),
                                  ),
                                );
                              },
                            ),
                            if (_cartItemsCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '$_cartItemsCount',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Products',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterProducts,
                  decoration: InputDecoration(
                    hintText:
                        'Search products by name, description, price, shop...',
                    prefixIcon: Icon(Icons.search, color: Colors.blue.shade800),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ),

            // Results Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredProducts.length} product(s) found',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    Text(
                      'Search: "${_searchController.text}"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 10),

            // Products List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade800,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading products...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: Icon(Icons.refresh),
                            label: Text('Try Again'),
                            onPressed: () => get_products(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'No Products Available'
                                : 'No Products Found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Check back later for new products'
                                : 'Try different search terms',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_searchController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: ElevatedButton(
                                onPressed: _clearSearch,
                                child: Text('Clear Search'),
                              ),
                            ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => get_products(context),
                      color: Colors.blue.shade800,
                      child: ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(
                            filteredProducts[index],
                            index,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
