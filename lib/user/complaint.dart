import 'package:close_by_shop/user/register.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart'; // ✅ Make sure you import this

final dio = Dio();

class Complaintpage extends StatefulWidget {
  const Complaintpage({super.key});

  @override
  State<Complaintpage> createState() => _ComplaintpageState();
}

class _ComplaintpageState extends State<Complaintpage> {
  TextEditingController comp = TextEditingController();
  List<dynamic> replay = [];

  Future<void> get_Replay(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? loginid = prefs.getInt('login_id');

      final response = await dio.get('$baseurl/Complaint_API/$loginid');
      print(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          replay = response.data;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to fetch complaints')));
      }
    } catch (e) {
      print("Error in get_Replay: $e");
    }
  }

  Future<void> post_com(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? loginid = prefs.getInt('login_id');

      final response = await dio.post(
        '$baseurl/Complaint_API/$loginid',
        data: {'Complaint': comp.text},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully')),
        );
        comp.clear();
        await get_Replay(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit complaint')),
        );
      }
    } catch (e) {
      print("Error in post_com: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      get_Replay(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Image.asset('assets/images/logo.png', height: 90, width: 90),
              const Text(
                'Close By Shop Search',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 50),
              const Text(
                'Submit a Complaint',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
              ),
              const Text(
                "Tell Us What's Wrong",
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 60),
              TextFormField(
                maxLines: 8,
                controller: comp,
                decoration: InputDecoration(
                  labelText: 'Please Describe Your Issue Here',
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
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => post_com(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade800,
                  minimumSize: const Size(250, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'SUBMIT',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Fixed Replay Section
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
                    const SizedBox(height: 10),
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
                                        replay[index]['Reply'] ?? 'No reply yet',
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
    );
  }
}
