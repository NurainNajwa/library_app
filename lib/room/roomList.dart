import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reserveRoom.dart';

class RoomList extends StatefulWidget {
  const RoomList({Key? key}) : super(key: key);

  @override
  RoomListState createState() => RoomListState();
}

class RoomListState extends State<RoomList> {
  late CollectionReference _roomsCollection;

  @override
  void initState() {
    super.initState();
    _roomsCollection = FirebaseFirestore.instance.collection('Rooms');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30), // Adding space here
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Room List',
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
              stream: _roomsCollection.snapshots(),
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
                    child: Text('No rooms available'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var room = snapshot.data!.docs[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 1.0),
                        ),
                      ),
                      child: ListTile(
                        title: Text(room['name'].toString()),
                        subtitle:
                            Text('Capacity: ${room['capacity'].toString()}'),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            // Navigate to reservation page with the selected room
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddReservation(room: room),
                              ),
                            ).then((_) {
                              // Trigger a rebuild to update the UI after returning
                              setState(() {});
                            });
                          },
                        ),
                        onTap: () {
                          // Navigate to reservation page with the selected room
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddReservation(room: room),
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
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}
