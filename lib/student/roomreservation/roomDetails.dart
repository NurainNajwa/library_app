import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoomDetails extends StatefulWidget {
  final String roomId;

  const RoomDetails({Key? key, required this.roomId}) : super(key: key);

  @override
  _RoomDetailsState createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<RoomDetails> {
  late Future<DocumentSnapshot> _roomDetails;
  late String borrowerId;

  @override
  void initState() {
    super.initState();
    _roomDetails = getRoomDetails(widget.roomId);
    borrowerId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Room Details',
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
                Color(0xffB81736),
                Color(0xff281537),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _roomDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Error fetching data'));
          }

          final roomData = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Room Type: ${roomData['roomType']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Room Number: ${roomData['roomNumber']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Capacity: ${roomData['capacity']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Status: ${roomData['status']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: roomData['status'] == 'Available'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                SizedBox(height: 16),
                if (roomData['status'] == 'Available')
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _reserveRoom(snapshot.data!.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color.fromRGBO(121, 37, 65, 1), // Background color
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30), // Rounded corners
                        ),
                      ),
                      child: Text(
                        'Reserve Room',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _cancelReservation(snapshot.data!.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Background color
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30), // Rounded corners
                        ),
                      ),
                      child: Text(
                        'Cancel Reservation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<DocumentSnapshot> getRoomDetails(String roomId) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('Rooms').doc(roomId).get();

    return snapshot;
  }

  Future<void> _reserveRoom(String roomId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference roomRef =
        FirebaseFirestore.instance.collection('Rooms').doc(roomId);

    await roomRef.update({'status': 'Booked'});

    CollectionReference roomReservations =
        FirebaseFirestore.instance.collection('Reservations');

    await roomReservations.add({
      'roomId': roomId,
      'userId': userId,
      'date': Timestamp.now(),
    });

    // Add notification
    CollectionReference notifications =
        FirebaseFirestore.instance.collection('Notifications');

    DateTime notificationDate = DateTime.now()
        .add(Duration(days: 7)); // or your preferred notification date
    await notifications.add({
      'userId': userId,
      'type': 'room',
      'itemId': roomId,
      'date': Timestamp.fromDate(notificationDate),
      'status': 'upcoming',
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Room reserved successfully'),
    ));
  }

  Future<void> _cancelReservation(String roomId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference roomRef =
        FirebaseFirestore.instance.collection('Rooms').doc(roomId);

    await roomRef.update({'status': 'Available'});

    // Remove room reservation
    CollectionReference roomReservations =
        FirebaseFirestore.instance.collection('Reservations');

    QuerySnapshot reservationSnapshot = await roomReservations
        .where('roomId', isEqualTo: roomId)
        .where('userId', isEqualTo: userId)
        .get();

    for (QueryDocumentSnapshot doc in reservationSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete notification
    await deleteNotification(roomId);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Room reservation cancelled successfully'),
    ));
  }

  Future<void> deleteNotification(String roomId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference notifications =
        FirebaseFirestore.instance.collection('Notifications');

    QuerySnapshot notificationSnapshot = await notifications
        .where('userId', isEqualTo: userId)
        .where('itemId', isEqualTo: roomId)
        .get();

    for (QueryDocumentSnapshot doc in notificationSnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
