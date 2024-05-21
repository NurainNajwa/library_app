import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:library_app/student/roomreservation/deleteReservation.dart';
import 'package:library_app/student/roomreservation/updateReservation.dart';
import 'reserveRoom.dart';

class RoomList extends StatefulWidget {
  const RoomList({Key? key}) : super(key: key);

  @override
  RoomListState createState() => RoomListState();
}

class RoomListState extends State<RoomList> {
  final CollectionReference _reservationsCollection =
      FirebaseFirestore.instance.collection('Reservations');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reservation List',
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _reservationsCollection.snapshots(),
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
              child: Text('No reservations available'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var reservation = snapshot.data!.docs[index];
              var date = (reservation['date'] as Timestamp).toDate();
              var time = reservation['time'];

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 1.0),
                  ),
                ),
                child: ListTile(
                  title: Text('Room: ${reservation['room']}'),
                  subtitle: Text(
                      'Date: ${date.toLocal().toString().split(' ')[0]}\nTime: $time'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit, // Edit icon
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          // Navigate to update reservation page with the selected reservation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UpdateReservation(reservation: reservation),
                            ),
                          ).then((_) {
                            // Trigger a rebuild to update the UI after returning
                            setState(() {});
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete, // Delete icon
                          color: Colors.red,
                        ),
                        onPressed: () {
                          // Navigate to delete reservation page with the selected reservation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DeleteReservation(reservation: reservation),
                            ),
                          ).then((_) {
                            // Trigger a rebuild to update the UI after returning
                            setState(() {});
                          });
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to update reservation page with the selected reservation
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UpdateReservation(reservation: reservation),
                      ),
                    ).then((_) {
                      // Trigger a rebuild to update the UI after returning
                      setState(() {});
                    });
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add new reservation page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddReservation(),
            ),
          ).then((_) {
            // Trigger a rebuild to update the UI after returning
            setState(() {});
          });
        },
        backgroundColor: const Color(0xffB81736),
        child: const Icon(Icons.add), // Add icon
      ),
    );
  }
}
