import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logout'),
        backgroundColor: const Color(
            0xffB81736), // Match the login page's gradient start color
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushNamed(context, '/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(
                0xffB81736), // Match the login page's gradient start color
          ),
          child: const Text(
            'Logout',
            style: TextStyle(
              color: Colors.white, // Match the login page's text color
            ),
          ),
        ),
      ),
    );
  }
}
