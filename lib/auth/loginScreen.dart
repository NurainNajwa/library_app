import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:library_app/firebase_auth_implementation/firebase_auth_services.dart';
import 'forgotpasswordScreen.dart';
import 'regScreen.dart'; // Import the registration screen

class loginScreen extends StatefulWidget {
  const loginScreen({Key? key}) : super(key: key);
  @override
  State<loginScreen> createState() => _logScreen();
}

class _logScreen extends State<loginScreen> {
  final FirebaseAuthServices _auth = FirebaseAuthServices();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  late final TextEditingController? controller;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                'Hello\nSign in!',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
                        'Email', Icons.email, _emailController),
                    const SizedBox(height: 20),
                    buildPasswordTextFieldWithIcon('Password',
                        _passwordController), // Password field with eye icon
                    const SizedBox(height: 60),
                    GestureDetector(
                      onTap: _signInStudent,
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
                            'SIGN IN AS STUDENT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _signInLibrarian,
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
                            'SIGN IN AS LIBRARIAN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const forgotpasswordscreen(),
                          ),
                        );
                      },
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Color(0xff281537),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
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
                                  builder: (context) => const RegScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
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
        suffixIcon: Icon(icon, color: Colors.red), // Adjust the color here
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
    bool obscureText = true; // Initially obscure the text

    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.red,
          ),
          onPressed: () {
            setState(() {
              obscureText = !obscureText; // Toggle the visibility
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
  }

  void _signInStudent() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email != 'library@domain.com') {
      // Librarian login
      if (password.isNotEmpty) {
        // Proceed with librarian login
        try {
          User? userCredential = await _auth.signInWithEmailAndPassword(
            email,
            password,
          );

          if (userCredential != null) {
            print("Librarian is successfully signed in");
            Navigator.pushNamed(context, '/home');
          } else {
            print("Student sign in unsuccessful");
          }
        } catch (e) {
          print("Error signing in as student: $e");
          // Handle sign-in errors
        }
      } else {
        // Password is empty
        print("Password is required for student login");
      }
    }
  }

  void _signInLibrarian() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    // Check if the email is for a librarian
    if (email == 'library@domain.com') {
      // Librarian login
      if (password.isNotEmpty) {
        // Proceed with librarian login
        try {
          User? userCredential = await _auth.signInWithEmailAndPassword(
            email,
            password,
          );

          if (userCredential != null) {
            print("Librarian is successfully signed in");
            Navigator.pushNamed(context, '/librarian');
          } else {
            print("Librarian sign in unsuccessful");
          }
        } catch (e) {
          print("Error signing in as librarian: $e");
          // Handle sign-in errors
        }
      } else {
        // Password is empty
        print("Password is required for librarian login");
      }
    }
  }
}
