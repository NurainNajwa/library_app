import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:library_app/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'forgotpasswordScreen.dart';
import 'regScreen.dart'; // Import the registration screen

class loginScreen extends StatefulWidget {
  final bool isPasswordReset;

  const loginScreen({Key? key, this.isPasswordReset = false}) : super(key: key);
  @override
  State<loginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<loginScreen> {
  final FirebaseAuthServices _auth = FirebaseAuthServices();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool obscureText = true;

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
                'UTM Library\nManagement System',
                style: TextStyle(
                  fontSize: 25,
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
                      onTap: widget.isPasswordReset
                          ? _updatePassword
                          : _signInStudent,
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
                        child: Center(
                          child: Text(
                            widget.isPasswordReset
                                ? 'NEW PASSWORD'
                                : 'SIGN IN AS STUDENT',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!widget.isPasswordReset)
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
                    if (!widget.isPasswordReset) const SizedBox(height: 20),
                    if (!widget.isPasswordReset)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const forgotpasswordscreen(),
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
                    if (!widget.isPasswordReset)
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffB81736), Color(0xff281537)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Error",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Color(0xffB81736),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _signInStudent() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email != 'library@domain.com') {
      // Student login
      if (password.isNotEmpty) {
        // Proceed with student login
        try {
          User? userCredential = await _auth.signInWithEmailAndPassword(
            email,
            password,
          );

          if (userCredential != null) {
            print("Student is successfully signed in");
            Navigator.pushNamed(context, '/home');
          } else {
            _showErrorDialog("User does not exist.");
          }
        } catch (e) {
          print("Error signing in as student: $e");
          _showErrorDialog("Invalid password.");
        }
      } else {
        _showErrorDialog("Password is required for student login.");
      }
    } else {
      _showErrorDialog("Not a student.");
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
            _showErrorDialog("User does not exist.");
          }
        } catch (e) {
          print("Error signing in as librarian: $e");
          _showErrorDialog("Invalid password.");
        }
      } else {
        _showErrorDialog("Password is required for librarian login.");
      }
    } else {
      _showErrorDialog("Not a librarian.");
    }
  }

  void _updatePassword() async {
    String email = _emailController.text;
    String newPassword = _passwordController.text;

    if (newPassword.isNotEmpty) {
      try {
        // Assuming user is already authenticated and re-authenticated properly.
        // Update the password in Firestore
        final userCollection = FirebaseFirestore.instance.collection('Student');
        final querySnapshot =
            await userCollection.where('email', isEqualTo: email).get();
        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first;
          await userDoc.reference.update({'password': newPassword});

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password updated successfully!'),
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate back to login screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const loginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: User not found!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update password: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password cannot be empty!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
