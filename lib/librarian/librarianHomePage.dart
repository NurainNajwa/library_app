import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:library_app/librarian/bookList.dart';

class LibrarianHomePage extends StatefulWidget {
  const LibrarianHomePage({Key? key}) : super(key: key);

  @override
  LibrarianHomePageState createState() => LibrarianHomePageState();
}

class LibrarianHomePageState extends State<LibrarianHomePage> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Librarian Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xffB81736),
                const Color(0xff281537),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isMenuOpen = !_isMenuOpen;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                // Navigate to login screen after successful logout
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                print('Error logging out: $e');
                // Handle logout error here
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (_isMenuOpen) _buildMenu(),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildMenuItem(
                    icon: Icons.book,
                    title: 'Manage Books',
                    onTap: () {
                      // Navigate to manage books page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BookList()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.meeting_room,
                    title: 'Manage Rooms',
                    onTap: () {
                      // Navigate to manage rooms page
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.bar_chart,
                    title: 'Yearly Statistics',
                    onTap: () {
                      // Navigate to yearly statistics page
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
              height: 20), // Added space at the bottom for better spacing
        ],
      ),
    );
  }

  Widget _buildMenu() {
    return Container(
      color: const Color(0xffB81736), // Menu background color
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClickableText(
            text: 'Books',
            onTap: () {
              // Handle click on Books
            },
          ),
          _buildClickableText(
            text: 'Rooms',
            onTap: () {
              // Handle click on Rooms
            },
          ),
          _buildClickableText(
            text: 'Statistics',
            onTap: () {
              // Handle click on Statistics
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClickableText({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: const Color(0xffB81736), // Icon color
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xffB81736), // Text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
