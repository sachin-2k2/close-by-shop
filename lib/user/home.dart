import 'package:close_by_shop/user/complaint.dart';
import 'package:close_by_shop/user/login.dart';
import 'package:close_by_shop/user/nerabyshop.dart';
import 'package:close_by_shop/user/orderhistory.dart';
import 'package:close_by_shop/user/pricecomp.dart';
import 'package:close_by_shop/user/products.dart';
import 'package:close_by_shop/user/scan.dart';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  final double? userLatitude;
  final double? userLongitude;
  final double? userLocationAccuracy;

  const Homepage({
    super.key,
    this.userLatitude,
    this.userLongitude,
    this.userLocationAccuracy,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // File? _selectedImage;
  // final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Use the location data here
    if (widget.userLatitude != null && widget.userLongitude != null) {
      print("=== HOMEPAGE LOCATION DATA ===");
      print("Latitude: ${widget.userLatitude}");
      print("Longitude: ${widget.userLongitude}");
      print("Accuracy: ${widget.userLocationAccuracy} meters");
      print("==============================");

      // You can save this to shared preferences, database, or state management
      _saveUserLocation();
    }
  }

  void _saveUserLocation() {
    // Save location to shared preferences or your preferred storage
    // Example using shared_preferences (you'll need to add the package):
    /*
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_latitude', widget.userLatitude!);
    await prefs.setDouble('user_longitude', widget.userLongitude!);
    await prefs.setDouble('user_location_accuracy', widget.userLocationAccuracy!);
    */
  }

  void logout(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure want to Logout?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color.fromARGB(255, 12, 12, 12)),
            ),
          ),
          TextButton(
            onPressed: () {
              log_out_splash(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> log_out_splash(context) async {
    SharedPreferences logout = await SharedPreferences.getInstance();
    await logout.setBool('logged', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Loginpage()),
    );
  }

  // Function to show image source options
  // Future<void> _showImageSourceDialog() async {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Choose Image Source'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               ListTile(
  //                 leading: Icon(Icons.camera_alt),
  //                 title: Text('Camera'),
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   _pickImage(ImageSource.camera);
  //                 },
  //               ),
  //               ListTile(
  //                 leading: Icon(Icons.photo_library),
  //                 title: Text('Gallery'),
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   _pickImage(ImageSource.gallery);
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // Function to pick image from camera or gallery
  // Future<void> _pickImage(ImageSource source) async {
  //   try {
  //     final XFile? pickedFile = await _picker.pickImage(source: source);

  //     if (pickedFile != null) {
  //       setState(() {
  //         _selectedImage = File(pickedFile.path);
  //       });

  //       // Navigate to product results page with the selected image and location
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => ImageSearchPage()),
  //       );
  //     }
  //   } catch (e) {
  //     print('Error picking image: $e');
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Error selecting image')));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(239, 255, 255, 255),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Location Display Banner
                  if (widget.userLatitude != null &&
                      widget.userLongitude != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal.shade100),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.teal.shade800,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Location: ${widget.userLatitude!.toStringAsFixed(4)}, ${widget.userLongitude!.toStringAsFixed(4)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.teal.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Image.asset('assets/images/logo.png', height: 90, width: 90),
                  Text(
                    'Close By Shop Search',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 80),
                  Text(
                    'Welcome, Name',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                  SizedBox(height: 10),

                  // Scan Product Section
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 130,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(91, 0, 0, 0),
                            blurStyle: BlurStyle.outer,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.teal.shade700,
                                  size: 40,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Scan a product',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 30.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageSearchPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade800,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Scan',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 50),

                  // First Row of Options
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      height: 150,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Pricecomparison(),
                                ),
                              );
                            },
                            child: Container(
                              height: 130,
                              width: 160,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 5,
                                    blurStyle: BlurStyle.outer,
                                    color: const Color.fromARGB(91, 0, 0, 0),
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  Icon(
                                    Icons.compare_arrows_rounded,
                                    color: Colors.teal.shade800,
                                    size: 40,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Price Comparison',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Nerabyshop(),
                                ),
                              );
                            },
                            child: Container(
                              height: 130,
                              width: 160,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10,
                                    blurStyle: BlurStyle.outer,
                                    color: const Color.fromARGB(91, 0, 0, 0),
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.teal.shade800,
                                    size: 40,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'View Nearby Shop',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Products(),
                                ),
                              );
                            },
                            child: Container(
                              height: 130,
                              width: 160,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 5,
                                    blurStyle: BlurStyle.outer,
                                    color: const Color.fromARGB(91, 0, 0, 0),
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  Icon(
                                    Icons.shopify_rounded,
                                    color: Colors.teal.shade800,
                                    size: 40,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Products',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // Second Row of Options
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      height: 150,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Complaintpage(),
                                ),
                              );
                            },
                            child: Container(
                              height: 130,
                              width: 160,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10,
                                    blurStyle: BlurStyle.outer,
                                    color: const Color.fromARGB(91, 0, 0, 0),
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  Icon(
                                    Icons.feed,
                                    color: Colors.teal.shade800,
                                    size: 40,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Send App Complaint',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Orderhistory(),
                                ),
                              );
                            },
                            child: Container(
                              height: 130,
                              width: 160,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10,
                                    blurStyle: BlurStyle.outer,
                                    color: const Color.fromARGB(91, 0, 0, 0),
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  Icon(
                                    Icons.history_sharp,
                                    color: Colors.teal.shade800,
                                    size: 40,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Order History',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          InkWell(
                            onTap: () {
                              logout(context);
                            },
                            child: Container(
                              height: 130,
                              width: 160,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10,
                                    blurStyle: BlurStyle.outer,
                                    color: const Color.fromARGB(91, 0, 0, 0),
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  Icon(
                                    Icons.logout_rounded,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
