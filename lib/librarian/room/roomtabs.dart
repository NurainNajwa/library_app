import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      length: 2, // Number of tabs
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
          .collection('Rooms')
          .where('userid', isEqualTo: bookerID)
          .where('status', isEqualTo: firestoreStatus)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<DocumentSnapshot> Reservations = snapshot.data!.docs;
          return ListView.builder(
            itemCount: Reservations.length,
            itemBuilder: (context, index) {
              var RoomData = Reservations[index];
              return ListTile(
                title: FutureBuilder<DocumentSnapshot>(
                  future: getRoomDetails(RoomData['roomid']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading...');
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      var Rooms = snapshot.data!;
                      return Text(
                          'Title: ${Rooms['title']}, Status: ${Rooms['status']}');
                    }
                  },
                ),
                subtitle: FutureBuilder<DocumentSnapshot>(
                  future: getRoomDetails(
                      RoomData['userid']), // Changed to getRoomDetails
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('booker: Loading...');
                    } else if (snapshot.hasError) {
                      return Text('Booker: Error: ${snapshot.error}');
                    } else {
                      var borrower = snapshot.data!;
                      return Text('Booker: ${borrower['name']}');
                    }
                  },
                ),
                trailing: status == 'Booked'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              _acceptRoomRequest(RoomData.id);
                            },
                            icon: Icon(Icons.check),
                          ),
                        ],
                      )
                    : status == 'Completed'
                        ? IconButton(
                            onPressed: () {
                              _completeAvailable(RoomData.id);
                            },
                            icon: Icon(Icons.check),
                          )
                        : null,
              );
            },
          );
        }
      },
    );
  }

  Future<DocumentSnapshot> getRoomDetails(String roomid) async {
    return await FirebaseFirestore.instance
        .collection('Rooms')
        .doc(roomid)
        .get();
  }

  Future<void> _acceptRoomRequest(String roomID) async {
    await FirebaseFirestore.instance.collection('Rooms').doc(roomID).update({
      'status': 'Completed',
    });
  }

  Future<void> _completeAvailable(String roomID) async {
    await FirebaseFirestore.instance.collection('Rooms').doc(roomID).update({
      'status': 'available',
    });
  }
}
