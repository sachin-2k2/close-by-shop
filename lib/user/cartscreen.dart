import 'package:close_by_shop/user/payement.dart';
import 'package:close_by_shop/user/products.dart';
import 'package:close_by_shop/user/register.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

List<dynamic> cartItems = [];
double _grandTotal = 0.0;

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    get_cart(context);
  }

  Future<void> get_cart(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? loginid = prefs.getInt('login_id');

      if (loginid == null) {
        setState(() {
          _errorMessage = 'Please login to view your cart';
          _isLoading = false;
        });
        return;
      }

      final response = await dio.get(
        '$baseurl/fetchcart/',
        data: {'loginid': loginid}, // FIXED: Use queryParameters for GET
      );

      print("Cart API Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          setState(() {
            cartItems = responseData['cart_items'] ?? [];
            _grandTotal =
                (responseData['grand_total'] as num?)?.toDouble() ?? 0.0;
            _isLoading = false;
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Cart loaded successfully')));
        } else {
          setState(() {
            _errorMessage = 'Invalid response format';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch cart: ${response.statusCode}';
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to fetch cart')));
      }
    } catch (e) {
      print("Error in get_cart: $e");
      setState(() {
        _errorMessage = 'Error loading cart: $e';
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  Future<void> _updateQuantity(int index, int newQuantity) async {
    if (newQuantity < 1) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? loginid = prefs.getInt('login_id');

      if (loginid == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please login to update cart')));
        return;
      }

      final response = await dio.post(
        '$baseurl/updatecartqty/',
        data: {'cartid': cartItems[index]['id'], 'qty': newQuantity},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await get_cart(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Quantity updated')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update quantity')));
      }
    } catch (e) {
      print("Error updating quantity: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating quantity')));
    }
  }

  Future<void> _removeItem(int index) async {
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
              Icon(Icons.delete_outline, color: Colors.red.shade600),
              SizedBox(width: 8),
              Text('Remove Item', style: TextStyle(color: Colors.red.shade600)),
            ],
          ),
          content: Text('Are you sure you want to remove this item from cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _removeFromAPI(index);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeFromAPI(int index) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? loginid = prefs.getInt('login_id');

      if (loginid == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please login to remove items')));
        return;
      }

      final response = await dio.post(
        '$baseurl/deletecartitem/',
        data: {
          // 'loginid': loginid,
          'cartid': cartItems[index]['id'],
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await get_cart(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Item removed from cart')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to remove item')));
      }
    } catch (e) {
      print("Error removing item: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error removing item')));
    }
  }

  // void _proceedToCheckout() {
  //   if (cartItems.isEmpty) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Your cart is empty')));
  //     return;
  //   }

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         title: Row(
  //           children: [
  //             Icon(Icons.shopping_cart_checkout, color: Colors.purple.shade800),
  //             SizedBox(width: 8),
  //             Text('Checkout', style: TextStyle(color: Colors.purple.shade800)),
  //           ],
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text('Proceed to checkout with:'),
  //             SizedBox(height: 8),
  //             Text(
  //               '${cartItems.length} items',
  //               style: TextStyle(fontWeight: FontWeight.bold),
  //             ),
  //             SizedBox(height: 4),
  //             Text(
  //               'Total: ₹${_grandTotal.toStringAsFixed(2)}',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.green.shade700,
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: Text(
  //               'Cancel',
  //               style: TextStyle(color: Colors.grey.shade600),
  //             ),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               List<int> cartIds = cartItems.map((item) => item['id'] as int).toList();
  //               // sends only one id
  //               Navigator.pushAndRemoveUntil(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => PaymentPage(
  //                     totalAmount: _grandTotal,
  //                     itemCount: cartItems.length,
  //                     cartItems: cartItems,
  //                     cartIds: cartIds,
  //                   ),
  //                 ),
  //                 (route) => route.isFirst,
  //               );
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.purple.shade800,
  //               foregroundColor: Colors.white,
  //             ),
  //             child: Text('Proceed to Pay'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }



void _proceedToCheckout() {
  if (cartItems.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Your cart is empty')),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Checkout"),
        content: Text("Proceed to payment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {

              // ✅ PRODUCT IDs (NOT cart id)
              List<int> productIds =
                  cartItems.map((item) => item['Product'] as int).toList();

              // ✅ Quantities
              List<int> quantities =
                  cartItems.map((item) => item['Qty'] as int? ?? 1).toList();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentPage(
                    totalAmount: _grandTotal,
                    itemCount: cartItems.length,
                    cartItems: cartItems,
                    productIds: productIds,   // ✅ correct one
                    quantities: quantities,
                  ),
                ),
                (route) => route.isFirst,
              );
            },
            child: Text("Proceed to Pay"),
          ),
        ],
      );
    },
  );
}

  // Future<void> _processCheckout() async {
  //   try {
  //     final SharedPreferences prefs = await SharedPreferences.getInstance();
  //     int? loginid = prefs.getInt('login_id');

  //     if (loginid == null) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Please login to checkout')));
  //       return;
  //     }

  //     final response = await dio.post(
  //       '$baseurl/placeorder/',
  //       data: {'loginid': loginid, 'total_amount': _grandTotal},
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => PaymentPage(
  //             totalAmount: _grandTotal,
  //             itemCount: cartItems.length,
  //             cartItems: cartItems,
  //           ),
  //         ),
  //       );
  //       // ScaffoldMessenger.of(context).showSnackBar(
  //       //   SnackBar(
  //       //     content: Text('Order placed successfully!'),
  //       //     backgroundColor: Colors.green.shade600,
  //       //   ),
  //       // );

  //       setState(() {
  //         cartItems.clear();
  //         _grandTotal = 0.0;
  //       });
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Checkout failed: ${response.data}')),
  //       );
  //     }
  //   } catch (e) {
  //     print("Error in checkout: $e");
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Checkout error: $e')));
  //   }
  // }

  String _buildImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/150';
    }

    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    if (imagePath.startsWith('/media')) {
      String base = baseurl.endsWith('/')
          ? baseurl.substring(0, baseurl.length - 1)
          : baseurl;
      String path = imagePath.startsWith('/') ? imagePath : '/$imagePath';
      return '$base$path';
    }

    // Handle relative paths without leading slash
    if (!imagePath.startsWith('/')) {
      imagePath = '/media/$imagePath'; // Assuming images are in media directory
    }

    String base = baseurl.endsWith('/')
        ? baseurl.substring(0, baseurl.length - 1)
        : baseurl;
    return '$base$imagePath';
  }

  Widget _buildCartItem(dynamic item, int index) {
    String imageUrl = _buildImageUrl(item['Img']);
    String productName = item['productname']?.toString() ?? 'Unknown Product';
    String description = item['description']?.toString() ?? 'No description';
    String price = item['Price']?.toString() ?? '0';
    String productType = item['ProductsType']?.toString() ?? 'N/A';
    int quantity = item['Qty'] ?? 1;
    double itemPrice = double.tryParse(price) ?? 0;
    double totalPrice = itemPrice * quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.purple.shade50,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.purple.shade100,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.purple.shade800,
                          ),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      return Container(
                        color: Colors.purple.shade100,
                        child: Icon(
                          Icons.shopping_bag,
                          color: Colors.purple.shade800,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name and Delete Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            productName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.purple.shade900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          onPressed: () => _removeItem(index),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(minWidth: 40),
                        ),
                      ],
                    ),

                    SizedBox(height: 6),

                    // Description
                    if (description.isNotEmpty &&
                        description != 'No description')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Price and Product Type
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 14,
                          color: Colors.green.shade700,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '₹$itemPrice',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                        if (productType != 'N/A') ...[
                          SizedBox(width: 12),
                          Icon(
                            Icons.category,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 4),
                          Text(
                            productType,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 12),

                    // Quantity Controls and Total Price
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Quantity:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          SizedBox(width: 8),

                          // Quantity Controls
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.purple.shade200),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.remove,
                                        size: 16,
                                        color: Colors.purple.shade800,
                                      ),
                                      onPressed: () =>
                                          _updateQuantity(index, quantity - 1),
                                      padding: EdgeInsets.all(4),
                                      constraints: BoxConstraints(minWidth: 32),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        '$quantity',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple.shade800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.add,
                                        size: 16,
                                        color: Colors.purple.shade800,
                                      ),
                                      onPressed: () =>
                                          _updateQuantity(index, quantity + 1),
                                      padding: EdgeInsets.all(4),
                                      constraints: BoxConstraints(minWidth: 32),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Item Total',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      '₹${totalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple.shade800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Total Price
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(239, 255, 255, 255),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
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
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.purple.shade800,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 8),
                    Image.asset(
                      'assets/images/logo.png',
                      height: 40,
                      width: 40,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Close By Shop Search',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'My Cart',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.purple.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Cart Summary
            if (!_isLoading && cartItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.purple.shade50, Colors.white],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.shade100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Summary',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade800,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '${cartItems.length} items',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '₹${_grandTotal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(
                          Icons.shopping_cart_checkout,
                          size: 40,
                          color: Colors.purple.shade300,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            SizedBox(height: 8),

            // Cart Items List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.purple.shade800,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading cart items...',
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
                            onPressed: () => get_cart(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade800,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Your Cart is Empty',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add some products to your cart',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade800,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Text('Continue Shopping'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => get_cart(context),
                      color: Colors.purple.shade800,
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          return _buildCartItem(cartItems[index], index);
                        },
                      ),
                    ),
            ),

            // Checkout Button
            if (!_isLoading && cartItems.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _proceedToCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '₹${_grandTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
