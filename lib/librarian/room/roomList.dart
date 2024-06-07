import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addRoom.dart';
import 'deleteRoom.dart';
import 'updateRoom.dart';
import 'searchRoom.dart'; // Import the searchRoom.dart file

class RoomList extends StatefulWidget {
  const RoomList({Key? key}) : super(key: key);

  @override
  RoomListState createState() => RoomListState();
}

class RoomListState extends State<RoomList> {
  final CollectionReference _roomsCollection =
      FirebaseFirestore.instance.collection('Rooms'); // Changed to 'Rooms'
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<QueryDocumentSnapshot> _filteredRooms = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchRooms(_searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchRooms(String query) async {
    var searchRoom = SearchRoom();
    var results = await searchRoom.searchRooms(query);
    setState(() {
      _filteredRooms = results;
    });
  }

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Rooms',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchRooms(_searchController.text.trim().toLowerCase());
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                if (_searchQuery.isEmpty) {
                  // Display all rooms if search query is empty
                  _filteredRooms = snapshot.data!.docs;
                }

                if (_filteredRooms.isEmpty) {
                  return const Center(
                    child: Text('No rooms available'),
                  );
                }

                return ListView.builder(
                  itemCount: _filteredRooms.length,
                  itemBuilder: (context, index) {
                    var room = _filteredRooms[index];
                    var roomData = room.data() as Map<String, dynamic>;

                    // Check if the necessary fields exist
                    if (!roomData.containsKey('roomType') ||
                        !roomData.containsKey('capacity')) {
                      return ListTile(
                        title: const Text('Invalid room data'),
                        subtitle: const Text('Please check the room details'),
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
                        title: Text(
                          roomData['roomType'].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          'Capacity: ${roomData['capacity'].toString()}',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black54,
                          ),
                        ),
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
                                    builder: (context) =>
                                        UpdateRoom(room: room),
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
                                    builder: (context) =>
                                        DeleteRoomPage(room: room),
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
          ),
        ],
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
