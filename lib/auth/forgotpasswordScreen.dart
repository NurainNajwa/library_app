import 'package:flutter/material.dart';
import 'loginScreen.dart'; // Ensure the LoginScreen class is properly imported

class forgotpasswordscreen extends StatelessWidget {
  const forgotpasswordscreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffB81736), Color(0xff281537)],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your email to reset your password',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextFormField(
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _sendPasswordResetEmail(context);
              },
              child: Container(
                height: 55,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xffB81736), Color(0xff281537)],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  border: Border.all(color: Colors.black),
                ),
                child: const Center(
                  child: Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to send password reset email
  void _sendPasswordResetEmail(BuildContext context) {
    // Implement your actual logic here to send the password reset email
    // For demonstration purposes, we're just showing a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset email sent!'),
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate back to login screen after resetting password
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const loginScreen()),
    );
  }
}
