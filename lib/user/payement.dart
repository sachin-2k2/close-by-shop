import 'package:close_by_shop/user/login.dart';
import 'package:close_by_shop/user/products.dart';
import 'package:close_by_shop/user/register.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  final int itemCount;
  final List<dynamic> cartItems;
  final List<int> cartIds;

  const PaymentPage({
    super.key,
    required this.totalAmount,
    required this.itemCount,
    required this.cartItems,
    required this.cartIds,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int _selectedPaymentMethod = 0;
  bool _isProcessing = false;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 0,
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card,
      'color': Colors.blue.shade800,
    },
    {
      'id': 1,
      'name': 'UPI Payment',
      'icon': Icons.qr_code,
      'color': Colors.purple.shade800,
    },
    {
      'id': 2,
      'name': 'Net Banking',
      'icon': Icons.account_balance,
      'color': Colors.green.shade800,
    },
    {
      'id': 3,
      'name': 'Cash on Delivery',
      'icon': Icons.local_atm,
      'color': Colors.orange.shade800,
    },
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    if (_selectedPaymentMethod == 0 &&
        (_cardNumberController.text.isEmpty ||
            _expiryController.text.isEmpty ||
            _cvvController.text.isEmpty ||
            _nameController.text.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all card details')));
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? loginid = prefs.getInt('login_id');

      if (loginid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login to complete payment')),
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Get payment method string
      String paymentMethod = _getPaymentMethodString();

      // Make API call to place order with cart IDs
      final response = await dio.post(
        '$baseurl/placeorder/', // Your order placement API endpoint
        data: {
          'loginid': loginid,
          'total_amount': widget.totalAmount,
          'cartid': widget.cartIds, // Use the cart IDs list
          'payment_method': paymentMethod,
          'payment_status': 'completed',
          // 'order_date': DateTime.now().toIso8601String(),
        },
      );

      print("Order API Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Order placed successfully
        final responseData = response.data;

        // Show success dialog
        _showPaymentSuccess(
          orderId:
              responseData['order_id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
        );

        // Clear the cart after successful order
        // await _clearCartAfterPayment(loginid);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order failed: ${response.data}')),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      print("Error in payment processing: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment error: Please try again')),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  String _getPaymentMethodString() {
    switch (_selectedPaymentMethod) {
      case 0:
        return 'card';
      case 1:
        return 'upi';
      case 2:
        return 'netbanking';
      case 3:
        return 'cod';
      default:
        return 'card';
    }
  }

  // Future<void> _clearCartAfterPayment() async {
  //   try {
  //     // Clear the cart items that were just ordered

  //     await dio.post(
  //       '$baseurl/deletecartitem/',
  //       data: {'loginid': loginid, 'cartid': widget.cartIds},
  //     );

  //     print("Cart cleared successfully for IDs: ${widget.cartIds}");
  //   } catch (e) {
  //     print("Error clearing cart: $e");
  //     // Don't show error to user as order is already placed
  //   }
  // }

  void _showPaymentSuccess({String orderId = ''}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 80,
                ),
                SizedBox(height: 16),
                Text(
                  'Order Placed Successfully!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '₹${widget.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
                SizedBox(height: 8),
                if (orderId.isNotEmpty) ...[
                  Text(
                    'Order ID: #$orderId',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 8),
                ],
                Text(
                  '${widget.itemCount} items • ${_getPaymentMethodString().toUpperCase()}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                SizedBox(height: 8),
                Text(
                  'Your order has been placed successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // _clearCartAfterPayment();
                      // Navigate back to home screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Products()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue Shopping',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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

    if (!imagePath.startsWith('/')) {
      imagePath = '/media/$imagePath';
    }

    String base = baseurl.endsWith('/')
        ? baseurl.substring(0, baseurl.length - 1)
        : baseurl;
    return '$base$imagePath';
  }

  Widget _buildOrderItem(dynamic item, int index) {
    String imageUrl = _buildImageUrl(item['Img']);
    String productName = item['productname']?.toString() ?? 'Unknown Product';
    String price = item['Price']?.toString() ?? '0';
    int quantity = item['Qty'] ?? 1;
    double itemPrice = double.tryParse(price) ?? 0;
    double totalPrice = itemPrice * quantity;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.purple.shade50,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
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
                      size: 20,
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.purple.shade900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹$itemPrice',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '× $quantity',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Item Total
          Text(
            '₹${totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.purple.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.shopping_bag, color: Colors.purple.shade800),
                SizedBox(width: 8),
                Text(
                  'Order Items (${widget.itemCount})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
              ],
            ),
          ),

          // Items List
          Container(
            constraints: BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  ...widget.cartItems.asMap().entries.map(
                    (entry) => _buildOrderItem(entry.value, entry.key),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade800,
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            prefixIcon: Icon(Icons.credit_card, color: Colors.purple.shade800),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.purple.shade800),
            ),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _expiryController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  prefixIcon: Icon(
                    Icons.calendar_today,
                    color: Colors.purple.shade800,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.purple.shade800),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  prefixIcon: Icon(Icons.lock, color: Colors.purple.shade800),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.purple.shade800),
                  ),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Cardholder Name',
            hintText: 'John Doe',
            prefixIcon: Icon(Icons.person, color: Colors.purple.shade800),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.purple.shade800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUPIPayment() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 80,
                color: Colors.purple.shade800,
              ),
              SizedBox(height: 16),
              Text(
                'Scan QR Code to Pay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Use any UPI app to scan and pay',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Enter UPI ID',
            hintText: 'username@upi',
            prefixIcon: Icon(Icons.payment, color: Colors.purple.shade800),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.purple.shade800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetBanking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Bank',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade800,
          ),
        ),
        SizedBox(height: 16),
        ...[
              'State Bank of India',
              'HDFC Bank',
              'ICICI Bank',
              'Axis Bank',
              'Kotak Mahindra Bank',
            ]
            .map(
              (bank) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.account_balance,
                      color: Colors.purple.shade800,
                    ),
                    title: Text(bank),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Handle bank selection
                    },
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildCashOnDelivery() {
    return Column(
      children: [
        Icon(Icons.local_atm, size: 80, color: Colors.orange.shade800),
        SizedBox(height: 16),
        Text(
          'Pay when you receive your order',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade800,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Our delivery executive will collect the payment when your order is delivered',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Note: Order will be confirmed immediately',
            style: TextStyle(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
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
                    // IconButton(
                    //   icon: Icon(
                    //     Icons.arrow_back,
                    //     color: Colors.purple.shade800,
                    //   ),
                    //   onPressed: () => Navigator.pop(context),
                    // ),
                    // SizedBox(width: 8),
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
                            'Secure Payment',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.purple.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.lock, color: Colors.green.shade600, size: 24),
                  ],
                ),
              ),
            ),

            // Order Summary and Items
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Items Section
                    _buildOrderSummary(),

                    SizedBox(height: 20),

                    // Total Amount Card
                    Container(
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
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order Total',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade800,
                                  ),
                                ),
                                Text(
                                  '${widget.itemCount} items',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₹${widget.totalAmount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Payment Methods
                    Text(
                      'Select Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Payment Method Cards
                    Column(
                      children: _paymentMethods
                          .map(
                            (method) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedPaymentMethod == method['id']
                                      ? Colors.purple.shade50
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        _selectedPaymentMethod == method['id']
                                        ? Colors.purple.shade800
                                        : Colors.grey.shade300,
                                    width:
                                        _selectedPaymentMethod == method['id']
                                        ? 2
                                        : 1,
                                  ),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    method['icon'],
                                    color: method['color'],
                                    size: 28,
                                  ),
                                  title: Text(
                                    method['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  trailing:
                                      _selectedPaymentMethod == method['id']
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Colors.green.shade600,
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedPaymentMethod = method['id'];
                                    });
                                  },
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                    SizedBox(height: 24),

                    // Payment Form based on selection
                    if (_selectedPaymentMethod == 0) _buildCardPaymentForm(),
                    if (_selectedPaymentMethod == 1) _buildUPIPayment(),
                    if (_selectedPaymentMethod == 2) _buildNetBanking(),
                    if (_selectedPaymentMethod == 3) _buildCashOnDelivery(),

                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Pay Now Button
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
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Pay Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '₹${widget.totalAmount.toStringAsFixed(2)}',
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
