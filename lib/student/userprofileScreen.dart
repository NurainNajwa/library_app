import 'package:flutter/material.dart';
import '../auth/loginScreen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

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
      body: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          Center(
            child: Image.asset('lib/image/ali.jpg'),
          ),
          const SizedBox(height: 20),
          const Text(
            'AHMAD ALI BIN ABU',
            style: TextStyle(
              fontFamily: 'Alice',
              color: Color(0xFF822421),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'A21EC0001',
            style: TextStyle(
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
          const ProfileItem(
              icon: Icons.email, text: 'ahmadalia@graduate.utm.my'),
          const ProfileItem(icon: Icons.phone, text: '010-215678'),
          const ProfileItem(
            icon: Icons.school,
            text: 'Bachelor of Computer Science (Software Engineering)',
          ),
          const ProfileItem(icon: Icons.settings, text: 'User Profile Setting'),
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
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const ProfileItem({Key? key, required this.icon, required this.text});

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
