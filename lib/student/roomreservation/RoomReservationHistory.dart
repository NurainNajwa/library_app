import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoomReservationHistory extends StatefulWidget {
  @override
  _RoomReservationHistoryState createState() => _RoomReservationHistoryState();
}

class _RoomReservationHistoryState extends State<RoomReservationHistory> {
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<String> _getRoomType(String roomId) async {
    DocumentSnapshot roomSnapshot =
        await FirebaseFirestore.instance.collection('Rooms').doc(roomId).get();
    var roomData = roomSnapshot.data() as Map<String, dynamic>?;
    return roomData?['roomType'] ?? 'Unknown Room';
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return '${date.year}-${date.month}-${date.day} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteReservation(String reservationId, String roomId) async {
    // Remove room reservation
    await FirebaseFirestore.instance
        .collection('Reservations')
        .doc(reservationId)
        .delete();

    // Update room status
    await FirebaseFirestore.instance
        .collection('Rooms')
        .doc(roomId)
        .update({'status': 'Available'});

    // Delete notification
    await _deleteNotification(roomId);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Room reservation cancelled successfully'),
    ));
  }

  Future<void> _deleteNotification(String roomId) async {
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Reservations')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error fetching data'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No room reservations found'),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var reservation = snapshot.data!.docs[index];
            return FutureBuilder<String>(
              future: _getRoomType(reservation['roomId']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    title: Text('Loading...'),
                  );
                }
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15.0),
                    title: Text(
                      snapshot.data!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Reserved on: ${_formatDate(reservation['date'])}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black54,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _deleteReservation(
                            reservation.id, reservation['roomId']);
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
