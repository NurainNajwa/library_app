import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'roomDetails.dart';

class ReservRoomList extends StatefulWidget {
  const ReservRoomList({Key? key}) : super(key: key);

  @override
  ReservRoomListState createState() => ReservRoomListState();
}

class ReservRoomListState extends State<ReservRoomList> {
  final CollectionReference _roomsCollection =
      FirebaseFirestore.instance.collection('Room');
  String? _selectedRoomType;

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
            child: DropdownButton<String>(
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
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedRoomType == null
                  ? _roomsCollection.snapshots()
                  : _roomsCollection
                      .where('roomType', isEqualTo: _selectedRoomType)
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
                    child: Text('No rooms available'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var room = snapshot.data!.docs[index];
                    var roomData = room.data() as Map<String, dynamic>;

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
                        subtitle: Text(
                            'Capacity: ${roomData['capacity'].toString()}'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RoomDetails(roomid: room.id),
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
