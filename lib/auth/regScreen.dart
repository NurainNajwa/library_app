import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:library_app/firebase_auth_implementation/firebase_auth_services.dart';
import 'loginScreen.dart';

class RegScreen extends StatefulWidget {
  const RegScreen({Key? key}) : super(key: key); // Fixed key parameter
  @override
  State<RegScreen> createState() => _RegScreenState();
}

class _RegScreenState extends State<RegScreen> {
  final FirebaseAuthServices _auth = FirebaseAuthServices();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _matricnumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmpasswordController = TextEditingController();
  TextEditingController _courseController = TextEditingController();
  bool obscureText = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _matricnumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xffB81736),
                Color(0xff281537),
              ]),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                'Create Your\nAccount',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildTextFieldWithIcon(
                        'Full Name', Icons.person, _usernameController),
                    buildTextFieldWithIcon('Matric Number',
                        Icons.confirmation_number, _matricnumberController),
                    buildTextFieldWithIcon(
                        'Email', Icons.email, _emailController),
                    buildTextFieldWithIcon(
                        'Course', Icons.book, _courseController),
                    buildPasswordTextFieldWithIcon(
                        'Password', _passwordController),
                    buildPasswordTextFieldWithIcon(
                        'Confirm Password', _confirmpasswordController),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: _signUp,
                      child: Container(
                        height: 55,
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(colors: [
                            Color(0xffB81736),
                            Color(0xff281537),
                          ]),
                        ),
                        child: const Center(
                          child: Text(
                            'SIGN UP',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const loginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign In",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.black,
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
          ),
        ],
      ),
    );
  }

  Widget buildTextFieldWithIcon(
      String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: Icon(icon, color: Colors.red),
        labelText: label,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xffB81736),
        ),
      ),
    );
  }

  Widget buildPasswordTextFieldWithIcon(
      String label, TextEditingController controller) {
    return StatefulBuilder(
      builder: (context, setState) {
        return TextField(
          obscureText: obscureText,
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  obscureText = !obscureText;
                });
              },
            ),
            labelText: label,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xffB81736),
            ),
          ),
        );
      },
    );
  }

  void _signUp() async {
    String username = _usernameController.text;
    String matNo = _matricnumberController.text;
    String email = _emailController.text;
    String course = _courseController.text;
    String password = _passwordController.text;

    if (_passwordController.text != _confirmpasswordController.text) {
      // Passwords do not match
      print("Passwords do not match");
      return;
    }

    User? user = await _auth.signUpWithEmailAndPassword(email, password);
    if (user != null) {
      // Save additional user data to Firestore
      await FirebaseFirestore.instance.collection('Student').doc(user.uid).set({
        'course': course,
        'email': email,
        'matricno': matNo,
        'name': username,
        'userid': user.uid,
        'password': password
      });
      print("User is successfully created and data stored in Firestore");
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      print("Sign Up unsuccessful");
    }
  }
}
