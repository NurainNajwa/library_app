import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loginScreen.dart';

class forgotpasswordscreen extends StatefulWidget {
  const forgotpasswordscreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<forgotpasswordscreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSendingEmail = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
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
              onTap: _isSendingEmail
                  ? null
                  : () =>
                      _sendPasswordResetEmail(context, _emailController.text),
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
                child: Center(
                  child: _isSendingEmail
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
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
  void _sendPasswordResetEmail(BuildContext context, String email) async {
    setState(() {
      _isSendingEmail = true;
    });

    try {
      // Send the password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to login screen with password reset flag
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => loginScreen(isPasswordReset: true),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send password reset email: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isSendingEmail = false;
      });
    }
  }
}
