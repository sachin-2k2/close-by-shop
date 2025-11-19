import 'package:close_by_shop/user/home.dart';
import 'package:close_by_shop/user/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class splash_page extends StatefulWidget {
  const splash_page({super.key});

  @override
  State<splash_page> createState() => _splash_pasgeState();
}

class _splash_pasgeState extends State<splash_page> {
  Future<void> check_login() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool is_loged = pref.getBool('logged') ?? false;
    await Future.delayed(Duration(seconds: 1));
    if (is_loged) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Loginpage()),
      );
    }
  }

  @override
  void initState() {
    check_login();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CircleAvatar(
            //   backgroundColor: const Color.fromARGB(255, 251, 251, 251),
            //   radius: 100,
            //   backgroundImage: AssetImage('assets/images/icon.png'),
            // ),
            Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              child: Image.asset('assets/images/logo.png'),
            ),
            Text(
              'Close By Shope',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            Text('ShowCase.Conect.Innovate', style: TextStyle(fontSize: 8)),
          ],
        ),
      ),
    );
  }
}
