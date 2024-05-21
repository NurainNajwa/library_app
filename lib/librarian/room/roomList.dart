import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addRoom.dart';
import 'deleteRoom.dart';
import 'updateRoom.dart';

class RoomList extends StatefulWidget {
  const RoomList({Key? key}) : super(key: key);

  @override
  RoomListState createState() => RoomListState();
}

class RoomListState extends State<RoomList> {
  final CollectionReference _roomsCollection =
      FirebaseFirestore.instance.collection('Room');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              var roomData = room.data() as Map<String, dynamic>;

              // Check if the necessary fields exist
              if (!roomData.containsKey('roomType') ||
                  !roomData.containsKey('capacity')) {
                return ListTile(
                  title: const Text('Invalid room data'),
                  subtitle: const Text('Please check the room details'),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 1.0),
                  ),
                ),
                child: ListTile(
                  title: Text(roomData['roomType'].toString()),
                  subtitle:
                      Text('Capacity: ${roomData['capacity'].toString()}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          // Navigate to update room page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateRoom(room: room),
                            ),
                          ).then((_) {
                            setState(() {});
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeleteRoomPage(room: room),
                            ),
                          ).then((_) {
                            setState(() {});
                          });
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to update room page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateRoom(room: room),
                      ),
                    ).then((_) {
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
              builder: (context) => AddRoom(),
            ),
          ).then((_) {
            setState(() {});
          });
        },
        backgroundColor: const Color(0xffB81736),
        child: const Icon(Icons.add),
      ),
    );
  }
}
