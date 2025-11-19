import 'package:close_by_shop/user/register.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Product_Complaint extends StatefulWidget {
  final String orderid;
  const Product_Complaint({required this.orderid, super.key});

  @override
  State<Product_Complaint> createState() => _Product_ComplaintState();
}

List<dynamic> replay = [];

class _Product_ComplaintState extends State<Product_Complaint> {
  TextEditingController comp = TextEditingController();

  Future<void> post_com(context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? loginid = prefs.getInt('login_id');

      final response = await dio.post(
        '$baseurl/addcomplaint/',
        data: {
          'loginid': loginid,
          'orderid': widget.orderid,
          'complaint': comp.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully')),
        );
        comp.clear();
        // Refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit complaint')),
        );
      }
    } catch (e) {
      print("Error in post_com: $e");
    }
  }

  Future<void> get_replay(context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? loginid = prefs.getInt('login_id');

      final response = await dio.get('$baseurl/addcomplaint/$loginid');
      print("Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          // ✅ Handle both list or single object
          if (response.data is List) {
            replay = response.data;
          } else if (response.data is Map) {
            replay = [response.data];
          } else {
            replay = [];
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch complaint')),
        );
      }
    } catch (e) {
      print("Error fetching replay: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_replay(context);
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
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Image.asset('assets/images/logo.png', height: 90, width: 90),
                  Text(
                    'Close By Shop Search',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 50),
                  Text(
                    'Submit Order Complaint',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                  Text(
                    "Tell Us What's Wrong with The Order",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 60),
                  TextFormField(
                    controller: comp,
                    maxLines: 8,
                    decoration: InputDecoration(
                      label: Text('Please Describe Your Issue Here'),
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
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      post_com(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade800,
                      minimumSize: Size(250, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                    ),
                    child: Text(
                      'SUBMIT',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Replay :',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        ListView.builder(
                          itemCount: replay.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                title: Text(
                                  replay[index]['Complaint'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            replay[index]['Reply'] ??
                                                'No reply yet',
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [Text(replay[index]['Date'])],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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
