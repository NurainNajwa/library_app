import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'roomDetails.dart';
import 'searchRoom.dart'; // Import the searchRoom.dart file

class ReserveRoomList extends StatefulWidget {
  const ReserveRoomList({Key? key}) : super(key: key);

  @override
  ReserveRoomListState createState() => ReserveRoomListState();
}

class ReserveRoomListState extends State<ReserveRoomList> {
  final CollectionReference _roomsCollection =
      FirebaseFirestore.instance.collection('Rooms');
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedRoomType;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            child: Column(
              children: [
                TextField(
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
                        setState(() {
                          _searchQuery =
                              _searchController.text.trim().toLowerCase();
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: _selectedRoomType,
                  hint: const Text('Select Room Type'),
                  items: <String>[
                    'Study Group Room',
                    'Meeting Room',
                    'Activity Room',
                    'Seminar Room',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRoomType = newValue;
                    });
                  },
                ),
              ],
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

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No rooms available'),
                  );
                }

                // Filter rooms based on search query and selected room type
                var rooms = snapshot.data!.docs;
                if (_searchQuery.isNotEmpty || _selectedRoomType != null) {
                  rooms = rooms.where((doc) {
                    var roomData = doc.data() as Map<String, dynamic>;
                    var roomType = roomData['roomType'].toString().toLowerCase();
                    var capacity = roomData['capacity'].toString().toLowerCase();
                    var matchesSearchQuery = _searchQuery.isEmpty ||
                        roomType.contains(_searchQuery) ||
                        capacity.contains(_searchQuery);
                    var matchesRoomType = _selectedRoomType == null ||
                        roomType == _selectedRoomType!.toLowerCase();
                    return matchesSearchQuery && matchesRoomType;
                  }).toList();
                }

                return ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    var room = rooms[index];
                    var roomData = room.data() as Map<String, dynamic>;

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
                        contentPadding: const EdgeInsets.all(15.0),
                        title: Text(
                          roomData['roomType'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          'Capacity: ${roomData['capacity'].toString()}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black54,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward,
                          color: Colors.black54,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RoomDetails(roomId: room.id),
                              ));
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
    );
  }
}
