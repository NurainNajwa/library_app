import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:library_app/firebase_auth_implementation/firebase_auth_services.dart';

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
  late bool obscureText = true; // Declared obscureText variable

  @override
  void dispose() {
    _usernameController.dispose();
    _matricnumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
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
                    buildPasswordTextFieldWithIcon(
                        'Password', _passwordController),
                    buildPasswordTextFieldWithIcon(
                        'Confirm Password', _confirmpasswordController),
                    const SizedBox(height: 70),
                    GestureDetector(
                      onTap: _singUp,
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
        labelText: label, // Changed label to labelText
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xffB81736),
        ),
      ),
    );
  }

  Widget buildPasswordTextFieldWithIcon(
      String label, TextEditingController controller) {
    return TextField(
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
        labelText: label, // Changed label to labelText
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xffB81736),
        ),
      ),
    );
  }

  void _singUp() async {
    String username = _usernameController.text;
    String matNo = _matricnumberController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    User? user = await _auth.signUpWithEmailAndPassword(email, password);
    if (user != null) {
      print("User is successfully created ");
      Navigator.pushNamed(context, '/login');
    } else {
      print("Sign Up unsuccessful");
    }
  }
}
