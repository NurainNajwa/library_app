import 'package:flutter/material.dart';
import 'package:library_app/auth/welcomeScreen.dart';
import 'package:library_app/student/userprofileScreen.dart';
import 'package:library_app/student/bookingHistory.dart';
import 'package:library_app/student/notifications.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ));

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _menuVisible = false;
  int _notificationCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _fetchNotifications();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot notificationsSnapshot = await FirebaseFirestore.instance
        .collection('Notifications')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'upcoming')
        .get();

    setState(() {
      _notificationCount = notificationsSnapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UTM LIBRARY'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _menuVisible = !_menuVisible;
            });
          },
        ),
        actions: [
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 5, end: 5),
            badgeContent: Text(
              _notificationCount.toString(),
              style: TextStyle(color: Colors.white),
            ),
            child: IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsPage(),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const welcomeScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xffB81736),
            Color(0xff281537),
          ]),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Homepage',
                          style: TextStyle(color: Colors.black87, fontSize: 20),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(244, 243, 243, 1),
                              borderRadius: BorderRadius.circular(15)),
                          child: TextField(
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.black87,
                                ),
                                hintText: "Search you're looking for...",
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 15)),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Container(
                          width: 150.0,
                          height: 150.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              '10',
                              style: TextStyle(fontSize: 40.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Books read',
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  SizedBox(height: 20.0),
                  Align(
                    alignment: Alignment.center,
                    child: Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: [
                        _buildHomePageButton(
                          icon: Icons.book,
                          label: 'Books',
                          onPressed: () {
                            Navigator.pushNamed(context, '/booklistst');
                          },
                        ),
                        _buildHomePageButton(
                          icon: Icons.room,
                          label: 'Rooms',
                          onPressed: () {
                            Navigator.pushNamed(
                                context, '/reservationRoomList');
                          },
                        ),
                        _buildHomePageButton(
                          icon: Icons.person,
                          label: 'Profile',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserProfileScreen(),
                              ),
                            );
                          },
                        ),
                        _buildHomePageButton(
                          icon: Icons.history,
                          label: 'History',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingHistory(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
              if (_menuVisible)
                Positioned(
                  top: AppBar().preferredSize.height,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildMenuOption(
                          title: 'Home',
                          onTap: () {
                            setState(() {
                              _menuVisible = false;
                            });
                          },
                        ),
                        _buildMenuOption(
                          title: 'Books',
                          onTap: () {
                            Navigator.pushNamed(context, '/booklistst');
                            setState(() {
                              _menuVisible = false;
                            });
                          },
                        ),
                        _buildMenuOption(
                          title: 'Rooms',
                          onTap: () {
                            Navigator.pushNamed(
                                context, '/reservationRoomList');
                            setState(() {
                              _menuVisible = false;
                            });
                          },
                        ),
                        _buildMenuOption(
                          title: 'Profile',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserProfileScreen(),
                              ),
                            );
                            setState(() {
                              _menuVisible = false;
                            });
                          },
                        ),
                        _buildMenuOption(
                          title: 'History',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingHistory(),
                              ),
                            );
                            setState(() {
                              _menuVisible = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomePageButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Icon(
            icon,
            color: Color.fromRGBO(121, 37, 65, 1),
            size: 30,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildMenuOption({
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
