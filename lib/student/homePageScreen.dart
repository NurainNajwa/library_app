import 'package:flutter/material.dart';
import 'package:library_app/auth/welcomeScreen.dart';
import 'package:library_app/student/book/fineHistory.dart';
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
  double _totalFines = 0.0;
  Timer? _timer;
  int _bookReservationCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _fetchBookReservationCount();
    _fetchFines();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _fetchNotifications();
      _fetchFines();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchBookReservationCount() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
        .collection('bookReservations')
        .where('userId', isEqualTo: userId)
        .get();

    setState(() {
      _bookReservationCount = reservationSnapshot.docs.length;
    });
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

  Future<void> _fetchFines() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot finesSnapshot = await FirebaseFirestore.instance
        .collection('fines')
        .where('userId', isEqualTo: userId)
        .get();

    double totalFines = 0.0;
    for (var doc in finesSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      totalFines += data['fineAmount'];
    }

    setState(() {
      _totalFines = totalFines;
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
          gradient: LinearGradient(
            colors: [
              Color(0xffB81736),
              Color(0xff281537),
            ],
          ),
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
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.black87,
                              ),
                              hintText: "Search you're looking for...",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Align(
                    alignment: Alignment.center,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('bookReservations')
                          .where('userId',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          _bookReservationCount = snapshot.data!.docs.length;
                          return Column(
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
                                    '$_bookReservationCount',
                                    style: TextStyle(fontSize: 40.0),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                'Books Borrowed',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16.0),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                'Total Fines: MYR $_totalFines',
                                style: TextStyle(
                                    color: Colors.red, fontSize: 16.0),
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
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
                            String userId =
                                FirebaseAuth.instance.currentUser!.uid;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserProfileScreen(userid: userId),
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
                        _buildHomePageButton(
                          icon: Icons.money,
                          label: 'Fines',
                          onPressed: () {
                            String userId =
                                FirebaseAuth.instance.currentUser!.uid;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FineHistoryPage(userId: userId),
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
                            String userId =
                                FirebaseAuth.instance.currentUser!.uid;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserProfileScreen(userid: userId),
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
                        _buildMenuOption(
                          title: 'Fines',
                          onTap: () {
                            String userId =
                                FirebaseAuth.instance.currentUser!.uid;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserProfileScreen(userid: userId),
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
