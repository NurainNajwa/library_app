import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/loginScreen.dart';

class UserProfileScreen extends StatelessWidget {
  final String userid;

  const UserProfileScreen({Key? key, required this.userid}) : super(key: key);

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData() async {
    return await FirebaseFirestore.instance
        .collection('Student')
        .doc(userid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PROFILE',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'AbhayaLibre',
          ),
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
        centerTitle: true,
        backgroundColor: const Color(0xffB81736),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found.'));
          }

          var userData = snapshot.data!.data();
          if (userData == null) {
            return const Center(child: Text('No user data found.'));
          }

          return Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Center(
                child: Image.asset('lib/image/ali.jpg'),
              ),
              const SizedBox(height: 20),
              Text(
                userData['name'] ?? 'No name available',
                style: const TextStyle(
                  fontFamily: 'Alice',
                  color: Color(0xFF822421),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                userData['matricno'] ?? 'No student ID available',
                style: const TextStyle(
                  color: Color(0xFF822421),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                height: 3,
                color: const Color(0xffB81736),
                margin: const EdgeInsets.symmetric(vertical: 20),
              ),
              const SizedBox(height: 20),
              ProfileItem(
                icon: Icons.email,
                text: userData['email'] ?? 'No email available',
              ),
              ProfileItem(
                icon: Icons.school,
                text: userData['course'] ?? 'No course information available',
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const loginScreen(),
                    ),
                  );
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
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const ProfileItem({Key? key, required this.icon, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xffB81736)),
      title: Text(
        text,
        style: const TextStyle(color: Color(0xffB81736)),
      ),
    );
  }
}
