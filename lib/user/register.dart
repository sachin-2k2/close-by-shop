import 'package:close_by_shop/user/login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

final baseurl = 'http://192.168.1.45:5000';
Dio dio = Dio();

class _RegisterpageState extends State<Registerpage> {
  final formkey = GlobalKey<FormState>();
  bool obsecure = true;
  String gender = '';
  String? Date;
  final TextEditingController _dobController =
      TextEditingController(); // ✅ Added
  final TextEditingController name = TextEditingController(); // ✅ Added
  final TextEditingController email = TextEditingController(); // ✅ Added
  final TextEditingController address = TextEditingController(); // ✅ Added
  final TextEditingController Password = TextEditingController(); // ✅ Added
  final TextEditingController phno = TextEditingController(); // ✅ Added

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        Date = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
        _dobController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  Future<void> post_reg(context) async {
    try {
      final response = await dio.post(
        '$baseurl/Users_API',
        data: {
          'Username': email.text,
          'Password': Password.text,
          'Name': name.text,
          'Phone': phno.text,
          'Email': email.text,
          'DateofBirth': Date,
          'Gender': gender,
          'Address': address.text,
        },
      );

      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Loginpage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registration failed')));
      }
    } catch (e) {
      print("❌ Registration error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(239, 255, 255, 255),
      body: Center(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 90,
                      width: 90,
                    ),
                    const Text(
                      'Close By Shop Search',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 70),
                    const Text(
                      ' Create Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    const Text(
                      'Join as to start finding shops',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(184, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // ---------- Name ----------
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your Name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          labelText: 'Name',
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
                    // ---------- Email ----------
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your email';
                          } else if (!value.contains('@') ||
                              !value.endsWith('@gmail.com')) {
                            return 'Enter a Valid email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          labelText: 'Email',
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
                    // ---------- Phone ----------
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: phno,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your phone number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          labelText: 'Ph no',
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
                    // ---------- Address ----------
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: address,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your Address';
                          }
                          return null;
                        },
                        maxLines: 3,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          labelText: 'Address',
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
                    // ---------- DOB Field Added Here ----------
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _dobController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your Date of Birth';
                          }
                          return null;
                        },
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          labelText: 'Date of Birth',
                          suffixIcon: const Icon(Icons.calendar_today),
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
                    // ---------- Gender ----------
                    Row(
                      children: [
                        Checkbox(
                          side: BorderSide(
                            color: Colors.teal.shade800,
                            width: 2,
                          ),
                          activeColor: Colors.teal.shade800,
                          value: gender == 'Male',
                          onChanged: (value) {
                            setState(() {
                              gender = value! ? 'Male' : '';
                            });
                          },
                        ),
                        const Text('Male'),
                        Checkbox(
                          side: BorderSide(
                            color: Colors.teal.shade800,
                            width: 2,
                          ),
                          activeColor: Colors.teal.shade800,
                          value: gender == 'Female',
                          onChanged: (value) {
                            setState(() {
                              gender = value! ? 'Female' : '';
                            });
                          },
                        ),
                        const Text('Female'),
                        Checkbox(
                          side: BorderSide(
                            color: Colors.teal.shade800,
                            width: 2,
                          ),
                          activeColor: Colors.teal.shade800,
                          value: gender == 'Others',
                          onChanged: (value) {
                            setState(() {
                              gender = value! ? 'Others' : '';
                            });
                          },
                        ),
                        const Text('Others'),
                      ],
                    ),
                    // ---------- Password ----------
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: Password,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your Password';
                          } else if (value.length < 6) {
                            return 'Password should contain 6 charecters';
                          }
                          return null;
                        },
                        obscureText: obsecure,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
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
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (formkey.currentState!.validate()) {
                          if (gender.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select your gender'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }
                          post_reg(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade800,
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
