import 'package:close_by_shop/user/home.dart';
import 'package:close_by_shop/user/register.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart'; // Make sure you have dio imported

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

int? loginid;
double? longitude; // Define longitude variable
double? latitude;  // Define latitude variable


class _LoginpageState extends State<Loginpage> {
  final formkey = GlobalKey<FormState>();
  bool obsecure = true;
  Position? _currentPosition;
  String _locationMessage = "Fetching location...";
  bool _isLoadingLocation = false;
  bool _isLoggingIn = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> login_splash(context) async {
    SharedPreferences log_in = await SharedPreferences.getInstance();
    await log_in.setBool('logged', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Homepage(
          userLatitude: latitude,
          userLongitude: longitude,
          userLocationAccuracy: _currentPosition?.accuracy,
        ),
      ),
    );
  }

  Future<void> post_login(context) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please wait for location to be fetched')),
      );
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final response = await dio.post(
        '$baseurl/Login_API',
        data: {
          'Username': _usernameController.text.trim(),
          'Password': _passwordController.text.trim(),
          'Longitude': longitude, // Use the global variable
          'Latitude': latitude,   // Use the global variable
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print("API Response: ${response.data}");
      print("Sent Data - Username: ${_usernameController.text}, "
            "Longitude: $longitude, Latitude: $latitude");

      if (response.statusCode == 200 || response.statusCode == 201) {
        loginid = response.data['login_id'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('login_id', loginid!);
        
        // Also save location to shared preferences for future use
        await prefs.setDouble('user_longitude', longitude!);
        await prefs.setDouble('user_latitude', latitude!);
        
        print("Login successful. Login ID: $loginid");
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful')),
        );
        
        login_splash(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response.data}')),
        );
      }
    } catch (e) {
      print("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    } finally {
      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  // Function to get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationMessage = "Fetching location...";
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationMessage =
              "Location services are disabled. Please enable location services.";
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationMessage =
                "Location permissions are denied. Please enable in settings.";
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage =
              "Location permissions are permanently denied. Please enable in app settings.";
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );

      setState(() {
        _currentPosition = position;
        // Assign to global variables
        longitude = position.longitude;
        latitude = position.latitude;
        _locationMessage = "Location fetched successfully!";
        _isLoadingLocation = false;
      });

      print("=== LOCATION DATA FOR BACKEND ===");
      print("Latitude: $latitude");
      print("Longitude: $longitude");
      print("Accuracy: ${position.accuracy} meters");
      print("================================");

    } catch (e) {
      setState(() {
        _locationMessage = "Error fetching location: ${e.toString()}";
        _isLoadingLocation = false;
      });
      print("Error getting location: $e");
    }
  }

  // Function to open location settings
  Future<void> _openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Function to open app settings for permissions
  Future<void> _openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Image.asset(
                      'assets/images/logo.png',
                      height: 90,
                      width: 90,
                    ),
                    Text(
                      'Close By Shop Search',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 80),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      'Login to scan and search shops',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color.fromARGB(184, 0, 0, 0),
                      ),
                    ),

                    // Location Status Display
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _isLoadingLocation
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.teal.shade800,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      _currentPosition != null
                                          ? Icons.location_on
                                          : Icons.location_off,
                                      color: _currentPosition != null
                                          ? Colors.green
                                          : Colors.orange,
                                      size: 20,
                                    ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _locationMessage,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _currentPosition != null
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if (!_isLoadingLocation &&
                                  _currentPosition == null)
                                IconButton(
                                  icon: Icon(Icons.refresh, size: 20),
                                  onPressed: _getCurrentLocation,
                                  color: Colors.teal.shade800,
                                ),
                            ],
                          ),
                          if (_currentPosition != null) ...[
                            SizedBox(height: 8),
                            Text(
                              "Lat: ${latitude?.toStringAsFixed(6)}, "
                              "Lng: ${longitude?.toStringAsFixed(6)}",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Ready to send to backend",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          if (_locationMessage.contains("denied") ||
                              _locationMessage.contains("disabled")) ...[
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: _openLocationSettings,
                                  child: Text(
                                    "Enable Location",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.teal.shade800,
                                    ),
                                  ),
                                ),
                                Text("|", style: TextStyle(color: Colors.grey)),
                                TextButton(
                                  onPressed: _openAppSettings,
                                  child: Text(
                                    "App Settings",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.teal.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your Username';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: Colors.teal.shade500,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: Colors.teal.shade500,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your Password';
                          } else if (value.length < 6) {
                            return 'Password must contain 6 Characters';
                          }
                          return null;
                        },
                        obscureText: obsecure,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obsecure = !obsecure;
                              });
                            },
                            icon: Icon(
                              obsecure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                          ),
                          labelText: 'Password',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: Colors.teal.shade500,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: Colors.teal.shade500,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (_isLoadingLocation || _isLoggingIn)
                            ? null
                            : () {
                                if (formkey.currentState!.validate()) {
                                  if (_currentPosition == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Please wait for location to be fetched'),
                                      ),
                                    );
                                    return;
                                  }
                                  post_login(context);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoggingIn
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't Have An Account?",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 8, 8, 8),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Registerpage(),
                              ),
                            );
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.teal.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}