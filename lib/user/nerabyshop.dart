import 'package:close_by_shop/user/register.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:dio/dio.dart';

// Add these global variables if not already defined

class Nerabyshop extends StatefulWidget {
  const Nerabyshop({super.key});

  @override
  State<Nerabyshop> createState() => _NerabyshopState();
}

List<dynamic> shops = [];
List<dynamic> nearbyShops = []; // Filtered nearby shops

class _NerabyshopState extends State<Nerabyshop> {
  double? _userLatitude;
  double? _userLongitude;
  bool _isLoading = true;
  String _errorMessage = '';
  double _searchRadius = 10.0; // Default search radius in kilometers

  // Function to calculate distance between two coordinates using Haversine formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  // Function to filter nearby shops within a certain radius
  void filterNearbyShops(
    List<dynamic> allShops,
    double userLat,
    double userLon,
    double radiusKm,
  ) {
    nearbyShops = allShops.where((shop) {
      try {
        double shopLat = double.parse(shop['Latitude']?.toString() ?? '0');
        double shopLon = double.parse(shop['Longitude']?.toString() ?? '0');

        // Skip shops with invalid coordinates
        if (shopLat == 0.0 && shopLon == 0.0) {
          return false;
        }

        double distance = calculateDistance(userLat, userLon, shopLat, shopLon);
        return distance <= radiusKm;
      } catch (e) {
        print('Error parsing shop coordinates: $e');
        return false;
      }
    }).toList();

    // Sort by distance (nearest first)
    nearbyShops.sort((a, b) {
      try {
        double distA = calculateDistance(
          userLat,
          userLon,
          double.parse(a['Latitude']?.toString() ?? '0'),
          double.parse(a['Longitude']?.toString() ?? '0'),
        );
        double distB = calculateDistance(
          userLat,
          userLon,
          double.parse(b['Latitude']?.toString() ?? '0'),
          double.parse(b['Longitude']?.toString() ?? '0'),
        );
        return distA.compareTo(distB);
      } catch (e) {
        return 0;
      }
    });
  }

  Future<void> get_shops(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Get user location from shared preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _userLatitude = prefs.getDouble('user_latitude');
      _userLongitude = prefs.getDouble('user_longitude');

      print("User Location - Lat: $_userLatitude, Long: $_userLongitude");

      if (_userLatitude == null || _userLongitude == null) {
        setState(() {
          _errorMessage =
              'User location not found. Please login again to refresh your location.';
          _isLoading = false;
        });
        return;
      }

      final response = await dio.get('$baseurl/NearByLocation_API');
      print("API Response: ${response.data}");
      print(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> allShops = response.data;
        print("Total shops fetched: ${allShops.length}");

        // Filter shops within the specified radius
        filterNearbyShops(
          allShops,
          _userLatitude!,
          _userLongitude!,
          _searchRadius,
        );

        print("Nearby shops found: ${nearbyShops.length}");

        setState(() {
          shops = allShops;
          _isLoading = false;
        });

        if (nearbyShops.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No shops found within ${_searchRadius}km radius'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found ${nearbyShops.length} shops nearby'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch shops: ${response.statusCode}';
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to fetch shops')));
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _errorMessage = 'Error fetching shops: $e';
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  void _showRadiusDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Search Radius'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Adjust search radius (km)'),
                  SizedBox(height: 20),
                  Text(
                    '${_searchRadius.toStringAsFixed(1)} km',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Slider(
                    value: _searchRadius,
                    min: 1.0,
                    max: 50.0,
                    divisions: 49,
                    label: _searchRadius.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _searchRadius = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [1.0, 5.0, 10.0, 20.0, 50.0].map((radius) {
                      return ChoiceChip(
                        label: Text('${radius.toInt()}km'),
                        selected: _searchRadius == radius,
                        onSelected: (selected) {
                          setState(() {
                            _searchRadius = radius;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    get_shops(context); // Refresh with new radius
                  },
                  child: Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      get_shops(context);
    });
  }

  Widget _buildShopCard(dynamic shop, int index) {
    double shopLat = double.parse(shop['Latitude']?.toString() ?? '0');
    double shopLon = double.parse(shop['Longitude']?.toString() ?? '0');
    double distance = calculateDistance(
      _userLatitude!,
      _userLongitude!,
      shopLat,
      shopLon,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.teal.shade50],
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.teal.shade200, width: 2),
              ),
              child: ClipOval(
                child: shop['Img'] != null && shop['Img'].toString().isNotEmpty
                    ? Image.network(
                        shop['Img'].toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.teal.shade100,
                            child: Icon(
                              Icons.store,
                              color: Colors.teal.shade800,
                              size: 30,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.teal.shade100,
                        child: Icon(
                          Icons.store,
                          color: Colors.teal.shade800,
                          size: 30,
                        ),
                      ),
              ),
            ),
            title: Text(
              shop['Name']?.toString() ?? 'Unknown Shop',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.teal.shade900,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                // Address
                if (shop['Address'] != null &&
                    shop['Address'].toString().isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          shop['Address'].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 6),
                // Phone
                if (shop['Phone'] != null &&
                    shop['Phone'].toString().isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                      SizedBox(width: 6),
                      Text(
                        shop['Phone'].toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 6),
                // Email
                if (shop['Email'] != null &&
                    shop['Email'].toString().isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          shop['Email'].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 8),
                // Distance
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_walk,
                        size: 16,
                        color: Colors.teal.shade800,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${distance.toStringAsFixed(1)} km away',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.shade800,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward, color: Colors.white, size: 16),
            ),
            onTap: () {
              _showShopDetails(shop, distance);
            },
          ),
        ),
      ),
    );
  }

  void _showShopDetails(dynamic shop, double distance) {
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
              Icon(Icons.store, color: Colors.teal.shade800),
              SizedBox(width: 8),
              Text(
                'Shop Details',
                style: TextStyle(color: Colors.teal.shade800),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Shop Image
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.teal.shade50,
                  ),
                  child:
                      shop['Img'] != null && shop['Img'].toString().isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            shop['Img'].toString(),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.store,
                                  size: 60,
                                  color: Colors.teal.shade300,
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.store,
                            size: 60,
                            color: Colors.teal.shade300,
                          ),
                        ),
                ),
                SizedBox(height: 16),
                // Shop Name
                Text(
                  shop['Name']?.toString() ?? 'Unknown Shop',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade900,
                  ),
                ),
                SizedBox(height: 12),
                // Distance
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_walk, color: Colors.teal.shade800),
                      SizedBox(width: 8),
                      Text(
                        '${distance.toStringAsFixed(1)} kilometers away',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Details
                _buildDetailRow(
                  Icons.location_on,
                  'Address',
                  shop['Address']?.toString() ?? 'Not available',
                ),
                _buildDetailRow(
                  Icons.phone,
                  'Phone',
                  shop['Phone']?.toString() ?? 'Not available',
                ),
                _buildDetailRow(
                  Icons.email,
                  'Email',
                  shop['Email']?.toString() ?? 'Not available',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     // Add navigation or action here
            //     Navigator.of(context).pop();
            //   },
            //   child: Text('Get Directions'),
            // ),
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
          Icon(icon, size: 20, color: Colors.teal.shade600),
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
                child: Column(
                  children: [
                    Row(
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
                    SizedBox(height: 10),
                    Text(
                      'Nearby Shops',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Location and Controls Section
            if (_userLatitude != null && _userLongitude != null)
              Card(
                margin: EdgeInsets.all(12),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.teal.shade800),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Current Location',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Lat: ${_userLatitude!.toStringAsFixed(6)}, Lng: ${_userLongitude!.toStringAsFixed(6)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.teal.shade800,
                            ),
                            onPressed: () => get_shops(context),
                            tooltip: 'Refresh',
                          ),
                          IconButton(
                            icon: Icon(Icons.tune, color: Colors.teal.shade800),
                            onPressed: _showRadiusDialog,
                            tooltip: 'Adjust Radius',
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Searching within ${_searchRadius.toStringAsFixed(1)}km radius',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.teal.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Results Section
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.teal.shade800,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Finding nearby shops...',
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
                            onPressed: () => get_shops(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade800,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : nearbyShops.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.store_mall_directory_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No Shops Found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No shops found within ${_searchRadius}km radius',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _showRadiusDialog,
                            child: Text('Increase Search Radius'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => get_shops(context),
                      color: Colors.teal.shade800,
                      child: ListView.builder(
                        itemCount: nearbyShops.length,
                        itemBuilder: (context, index) {
                          return _buildShopCard(nearbyShops[index], index);
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
