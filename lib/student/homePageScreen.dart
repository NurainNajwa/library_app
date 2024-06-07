import 'package:flutter/material.dart';
import 'package:library_app/auth/welcomeScreen.dart';
import 'package:library_app/student/userprofileScreen.dart';
import 'package:library_app/student/bookingHistory.dart';

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
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Navigate to Notification
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const welcomeScreen(),
                ),
              ); // Perform log out action
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  SizedBox(height: 20.0),
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/booklistst');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Icon(Icons.book,
                                  color: Color.fromRGBO(121, 37, 65, 1),
                                  size: 30),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Books',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        SizedBox(width: 10.0),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to Rooms Page
                                Navigator.pushNamed(
                                    context, '/reservationRoomList');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Icon(Icons.room,
                                  color: Color.fromRGBO(121, 37, 65, 1),
                                  size: 30),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Rooms',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        SizedBox(width: 10.0),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const UserProfileScreen(),
                                  ),
                                ); // Navigate to Profile Page
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Icon(Icons.person,
                                  color: Color.fromRGBO(121, 37, 65, 1),
                                  size: 30),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Profile',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        SizedBox(width: 10.0),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingHistory(),
                                  ),
                                ); // Navigate to Booking History Page
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Icon(Icons.history,
                                  color: Color.fromRGBO(121, 37, 65, 1),
                                  size: 30),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'History',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
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
                    child: ListView(
                      children: [
                        ListTile(
                          title: Text('Home'),
                          onTap: () {
                            setState(() {
                              _menuVisible = false;
                            });
                          },
                        ),
                        ListTile(
                          title: Text('Books'),
                          onTap: () {
                            // Navigate to Books Page
                            Navigator.pushNamed(context, '/booklistst');
                            setState(() {
                              _menuVisible = false;
                            });
                          },
                        ),
                        ListTile(
                          title: Text('Rooms'),
                          onTap: () {
                            // Navigate to Rooms Page
                            Navigator.pushNamed(
                                context, '/reservationRoomList');
                            setState(() {
                              _menuVisible = false;
                            });
                          },
                        ),
                        ListTile(
                          title: Text('Profile'),
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
                        ListTile(
                          title: Text('History'),
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
}
