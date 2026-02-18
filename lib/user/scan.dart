// import 'dart:convert';
// import 'dart:io';
// import 'package:close_by_shop/user/register.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
//   import 'package:dio/dio.dart';

// class ImageSearchPage extends StatefulWidget {
//   @override
//   _ImageSearchPageState createState() => _ImageSearchPageState();
// }

// class _ImageSearchPageState extends State<ImageSearchPage> {
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();
//   bool _loading = false;
//   List _products = [];
//   String _detectedText = "";

//   // Function to show image source options
//   Future<void> _showImageSourceDialog() async {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Choose Image Source'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 ListTile(
//                   leading: Icon(Icons.camera_alt),
//                   title: Text('Camera'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImage(ImageSource.camera);
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.photo_library),
//                   title: Text('Gallery'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImage(ImageSource.gallery);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Function to pick image from camera or gallery
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(source: source);

//       if (pickedFile != null) {
//         setState(() {
//           _selectedImage = File(pickedFile.path);
//         });

//         // Upload image to API for product search
//         await _uploadImage(_selectedImage!);
//       }
//     } catch (e) {
//       print('Error picking image: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error selecting image: ${e.toString()}')),
//       );
//     }
//   }

//   // Upload image to API
//   // Future<void> _uploadImage(File imageFile) async {
//   //   setState(() {
//   //     _loading = true;
//   //     _products = [];
//   //     _detectedText = "";
//   //   });

//   //   try {
//   //     var uri = Uri.parse(
//   //       '$baseurl/product/',
//   //     ); // Replace with your actual API endpoint

//   //     var request = http.MultipartRequest("POST", uri);
//   //     request.files.add(
//   //       await http.MultipartFile.fromPath('image', imageFile.path),
//   //     );

//   //     var response = await request.send();

//   //     var responseData = await response.stream.bytesToString();
//   //     var data = jsonDecode(responseData);
//   //     print("Response Body: $response");
//   //     setState(() {
//   //       _loading = false;
//   //       _detectedText = data["text_detected"] ?? "";
//   //       _products = data["results"] ?? [];
//   //     });
//   //   } catch (e) {
//   //     print('Error uploading image: $e');
//   //     setState(() {
//   //       _loading = false;
//   //     });
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Error processing image: ${e.toString()}')),
//   //     );
//   //   }
//   // }






// Future<void> _uploadImage(File imageFile) async {
//   setState(() {
//     _loading = true;
//     _products = [];
//     _detectedText = "";
//   });

//   try {
   

//     FormData formData = FormData.fromMap({
//       "image": await MultipartFile.fromFile(
//         imageFile.path,
//         filename: imageFile.path.split('/').last,
//       ),
//     });

//     Response response = await dio.post(
//       '$baseurl/find-shops-by-image/',
//       data: formData,
//       options: Options(
//         headers: {
//           "Content-Type": "multipart/form-data",
//         },
//       ),
//     );

//     print("Status Code: ${response.statusCode}");
//     print("Response Body: ${response.data}");

//     var data = response.data;

//     setState(() {
//       _loading = false;
//       _detectedText = data["text_detected"] ?? "";
//       _products = data["results"] ?? [];
//     });

//   } on DioException catch (e) {
//     print("Dio Error: ${e.response?.data ?? e.message}");

//     setState(() {
//       _loading = false;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Error processing image: ${e.response?.data ?? e.message}',
//         ),
//       ),
//     );
//   } catch (e) {
//     print("Unexpected Error: $e");

//     setState(() {
//       _loading = false;
//     });
//   }
// }


//   // Clear current search
//   void _clearSearch() {
//     setState(() {
//       _selectedImage = null;
//       _products = [];
//       _detectedText = "";
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(239, 255, 255, 255),
//       appBar: AppBar(
//         title: Text("Search Product by Image"),
//         backgroundColor: Colors.teal.shade800,
//         elevation: 0,
//         actions: [
//           if (_selectedImage != null || _products.isNotEmpty)
//             IconButton(
//               icon: Icon(Icons.clear),
//               onPressed: _clearSearch,
//               tooltip: 'Clear Search',
//             ),
//         ],
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Instruction Text
//               Text(
//                 'Take a photo or choose from gallery to search for products',
//                 style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
//               ),
//               SizedBox(height: 20),

//               // Image Selection Section
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color.fromARGB(91, 0, 0, 0),
//                       blurStyle: BlurStyle.outer,
//                       blurRadius: 5,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     SizedBox(height: 20),

//                     // Selected Image Preview
//                     if (_selectedImage != null)
//                       Container(
//                         margin: EdgeInsets.symmetric(horizontal: 20),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.teal.shade300),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.file(
//                             _selectedImage!,
//                             height: 200,
//                             width: double.infinity,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       )
//                     else
//                       // Placeholder when no image is selected
//                       Container(
//                         height: 200,
//                         margin: EdgeInsets.symmetric(horizontal: 20),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                             color: Colors.grey.shade300,
//                             style: BorderStyle.solid,
//                           ),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.photo_camera_back,
//                               size: 50,
//                               color: Colors.grey.shade400,
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               'No image selected',
//                               style: TextStyle(
//                                 color: Colors.grey.shade500,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                     SizedBox(height: 20),

//                     // Scan Button
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           onPressed: _showImageSourceDialog,
//                           icon: Icon(Icons.camera_alt),
//                           label: Text(
//                             'Choose Image',
//                             style: TextStyle(fontSize: 16),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.teal.shade800,
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(vertical: 15),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: 20),

//               // Loading Indicator
//               if (_loading)
//                 Center(
//                   child: Column(
//                     children: [
//                       CircularProgressIndicator(),
//                       SizedBox(height: 10),
//                       Text(
//                         'Searching for products...',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.teal.shade800,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//               // Results Section
//               if (!_loading &&
//                   (_detectedText.isNotEmpty || _products.isNotEmpty))
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Detected Text
//                       if (_detectedText.isNotEmpty)
//                         Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.all(12),
//                           margin: EdgeInsets.only(bottom: 10),
//                           decoration: BoxDecoration(
//                             color: Colors.teal.shade50,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.teal.shade100),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Detected Text:',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.teal.shade800,
//                                 ),
//                               ),
//                               SizedBox(height: 5),
//                               Text(
//                                 _detectedText,
//                                 style: TextStyle(fontSize: 16),
//                               ),
//                             ],
//                           ),
//                         ),

//                       // Results Header
//                       if (_products.isNotEmpty)
//                         Text(
//                           'Found ${_products.length} product(s)',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.teal.shade800,
//                           ),
//                         ),

//                       SizedBox(height: 10),

//                       // Products List
//                       if (_products.isNotEmpty)
//                         Expanded(
//                           child: ListView.builder(
//                             itemCount: _products.length,
//                             itemBuilder: (context, index) {
//                               var product = _products[index];

//                               return Card(
//                                 elevation: 2,
//                                 margin: EdgeInsets.symmetric(vertical: 5),
//                                 child: ListTile(
//                                   leading: product["Img"] != null
//                                       ? ClipRRect(
//                                           borderRadius: BorderRadius.circular(
//                                             8,
//                                           ),
//                                           child: Image.network(
//                                             product["Img"],
//                                             width: 60,
//                                             height: 60,
//                                             fit: BoxFit.cover,
//                                             errorBuilder:
//                                                 (
//                                                   context,
//                                                   error,
//                                                   stackTrace,
//                                                 ) => Container(
//                                                   width: 60,
//                                                   height: 60,
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.grey.shade200,
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                           8,
//                                                         ),
//                                                   ),
//                                                   child: Icon(
//                                                     Icons.image_not_supported,
//                                                     size: 30,
//                                                     color: Colors.grey.shade400,
//                                                   ),
//                                                 ),
//                                           ),
//                                         )
//                                       : Container(
//                                           width: 60,
//                                           height: 60,
//                                           decoration: BoxDecoration(
//                                             color: Colors.grey.shade200,
//                                             borderRadius: BorderRadius.circular(
//                                               8,
//                                             ),
//                                           ),
//                                           child: Icon(
//                                             Icons.image_not_supported,
//                                             size: 30,
//                                             color: Colors.grey.shade400,
//                                           ),
//                                         ),
//                                   title: Text(
//                                     product["ProductName"] ?? "No name",
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   subtitle: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       SizedBox(height: 4),
//                                       Text(
//                                         "Type: ${product['ProductsType'] ?? 'N/A'}",
//                                         style: TextStyle(fontSize: 12),
//                                       ),
//                                       Text(
//                                         "Price: ₹${product['Price'] ?? 'N/A'}",
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.teal.shade700,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   onTap: () {
//                                     // Add product detail navigation if needed
//                                   },
//                                 ),
//                               );
//                             },
//                           ),
//                         )
//                       else if (!_loading &&
//                           _detectedText.isNotEmpty &&
//                           _products.isEmpty)
//                         Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.search_off,
//                                 size: 60,
//                                 color: Colors.grey.shade400,
//                               ),
//                               SizedBox(height: 10),
//                               Text(
//                                 'No products found',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),

//               // Empty State when no search performed
//               if (!_loading && _selectedImage == null && _products.isEmpty)
//                 Expanded(
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.photo_camera_back,
//                           size: 80,
//                           color: Colors.grey.shade300,
//                         ),
//                         SizedBox(height: 20),
//                         Text(
//                           'Select an image to search for products',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey.shade500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'dart:io';
import 'package:close_by_shop/user/register.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class ImageSearchPage extends StatefulWidget {
  @override
  _ImageSearchPageState createState() => _ImageSearchPageState();
}

class _ImageSearchPageState extends State<ImageSearchPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;
  List _products = [];
  String _detectedText = "";

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        await _uploadImage(_selectedImage!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: ${e.toString()}')),
      );
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _loading = true;
      _products = [];
      _detectedText = "";
    });

    try {
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      Response response = await dio.post(
        '$baseurl/find-shops-by-image/',
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      var data = response.data;

      setState(() {
        _loading = false;
        _detectedText = data["detected_product"] ?? "";
        _products = data["shops"] ?? [];
      });

    } on DioException catch (e) {
      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error processing image: ${e.response?.data ?? e.message}',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _selectedImage = null;
      _products = [];
      _detectedText = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(239, 255, 255, 255),
      appBar: AppBar(
        title: Text("Search Product by Image"),
        backgroundColor: Colors.teal.shade800,
        elevation: 0,
        actions: [
          if (_selectedImage != null || _products.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: _clearSearch,
              tooltip: 'Clear Search',
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                'Take a photo or choose from gallery to search for products',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              SizedBox(height: 20),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(91, 0, 0, 0),
                      blurStyle: BlurStyle.outer,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    if (_selectedImage != null)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera_back,
                              size: 50,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No image selected',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showImageSourceDialog,
                          icon: Icon(Icons.camera_alt),
                          label: Text(
                            'Choose Image',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade800,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              if (_loading)
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text(
                        'Searching for products...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

              if (!_loading &&
                  (_detectedText.isNotEmpty || _products.isNotEmpty))
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      if (_detectedText.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.teal.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detected Product:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade800,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                _detectedText,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),

                      if (_products.isNotEmpty)
                        Text(
                          'Found ${_products.length} shop(s)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade800,
                          ),
                        ),

                      SizedBox(height: 10),

                      if (_products.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              var product = _products[index];

                              return Card(
                                elevation: 2,
                                margin: EdgeInsets.symmetric(vertical: 5),
                                child: ListTile(
                                  leading: product["Img"] != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            "$baseurl${product["Img"]}",
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(Icons.store),

                                  title: Text(
                                    product["Name"] ?? "No name",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),

                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Text(
                                          "Address: ${product['Address'] ?? 'N/A'}"),
                                      Text(
                                          "Phone: ${product['Phone'] ?? 'N/A'}"),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
