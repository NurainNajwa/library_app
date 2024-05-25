import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RoomTabs extends StatefulWidget {
  final String RoomID;

  RoomTabs({Key? key, required this.RoomID}) : super(key: key);

  @override
  State<RoomTabs> createState() => _RoomTabsState();
}

class _RoomTabsState extends State<RoomTabs> {
  late String bookerID;

  @override
  void initState() {
    super.initState();
    bookerID = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Booked Rooms'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent('Booked'),
            _buildTabContent('Completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String status) {
    String firestoreStatus;
    if (status == 'Booked') {
      firestoreStatus = 'Booked';
    } else if (status == 'Completed') {
      firestoreStatus = 'Completed';
    } else {
      // Default to 'Complete' tab for 'Overdue' status
      firestoreStatus = 'Completed';
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Room')
          .where('userid', isEqualTo: bookerID)
          .where('status', isEqualTo: firestoreStatus)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<DocumentSnapshot> bookedRooms = snapshot.data!.docs;
          return ListView.builder(
            itemCount: bookedRooms.length,
            itemBuilder: (context, index) {
              var RoomData = bookedRooms[index];
              return ListTile(
                title: FutureBuilder<DocumentSnapshot>(
                  future: getRoomDetails(RoomData['Roomid']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading...');
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      var Room = snapshot.data!;
                      return Text('Title: ${Room['title']}, Status: ${Room['status']}');
                    }
                  },
                ),
                subtitle: FutureBuilder<DocumentSnapshot>(
                  future: getStudentDetails(RoomData['userid']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('booker: Loading...');
                    } else if (snapshot.hasError) {
                      return Text('booker: Error: ${snapshot.error}');
                    } else {
                      var booker = snapshot.data!;
                      return Text('booker: ${booker['name']}');
                    }
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<DocumentSnapshot> getRoomDetails(String Roomid) async {
    return await FirebaseFirestore.instance.collection('Room').doc(Roomid).get();
  }

  Future<DocumentSnapshot> getStudentDetails(String userid) async {
    return await FirebaseFirestore.instance.collection('Student').doc(userid).get();
  }

}
