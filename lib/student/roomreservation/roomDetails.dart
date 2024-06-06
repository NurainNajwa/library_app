import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Import RoomTabs page

class RoomDetails extends StatefulWidget {
  final String roomId;

  const RoomDetails({Key? key, required this.roomId}) : super(key: key);

  @override
  _RoomDetailsState createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<RoomDetails> {
  late Future<DocumentSnapshot> _RoomDetails;
  late String borrowerId;

  @override
  void initState() {
    super.initState();
    _RoomDetails = getRoomDetails(widget.roomId);
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
        future: _RoomDetails,
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
                    color: roomData['status'] == 'available'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                SizedBox(height: 16),
                if (roomData['status'] == 'available')
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _borrowRoom(snapshot.data!.id);
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
                  Text("Sorry, this room is already booked"),
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

    print("Room Data: ${snapshot.data()}");

    return snapshot;
  }

  Future<void> _borrowRoom(String roomId) async {
    DocumentReference bookRef =
        FirebaseFirestore.instance.collection('Rooms').doc(roomId);

    await bookRef.update({'status': 'Booked'});

    CollectionReference borrowedRoom =
        FirebaseFirestore.instance.collection('borrowedRooms');

    await borrowedRoom.add({
      'roomId': roomId,
      'userid': borrowerId,
      'borrowdate': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Room reserved successfully'),
    ));

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => RoomTabs(RoomID: roomId),
    //   ),
    // );
  }
}
