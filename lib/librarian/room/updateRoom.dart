import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateRoom extends StatefulWidget {
  final DocumentSnapshot room;

  const UpdateRoom({Key? key, required this.room}) : super(key: key);

  @override
  _UpdateRoomState createState() => _UpdateRoomState();
}

class _UpdateRoomState extends State<UpdateRoom> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _roomIdController;
  late TextEditingController _roomNumberController;
  late TextEditingController _capacityController;
  late TextEditingController _roomTypeController;
  late TextEditingController _statusController;

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with empty values or retrieve existing values if available
    _roomIdController = TextEditingController();
    _roomNumberController = TextEditingController();
    _capacityController = TextEditingController();
    _roomTypeController = TextEditingController();
    _statusController = TextEditingController();
    // Load existing room data if available
    loadRoomData();
  }

  @override
  void dispose() {
    // Dispose text controllers when the widget is disposed to avoid memory leaks
    _roomIdController.dispose();
    _roomNumberController.dispose();
    _capacityController.dispose();
    _roomTypeController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> loadRoomData() async {
    try {
      // Retrieve existing room data from Firebase Firestore based on roomId
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(widget.room.id)
          .get();
      if (documentSnapshot.exists) {
        // Populate text controllers with existing room data
        var data = documentSnapshot.data() as Map<String, dynamic>;
        _roomIdController.text = data['roomId'] ?? '';
        _roomNumberController.text = data['roomNumber'] ?? '';
        _capacityController.text = data['capacity'] ?? '';
        _roomTypeController.text = data['roomType'] ?? '';
        _statusController.text = data['status'] ?? '';
      }
    } catch (error) {
      print('Error loading room data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Room',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                TextFormField(
                  controller: _roomIdController,
                  decoration: InputDecoration(labelText: 'Room ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a room ID';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _roomNumberController,
                  decoration: InputDecoration(labelText: 'Room Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a room number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _capacityController,
                  decoration: InputDecoration(labelText: 'Capacity'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the capacity';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _roomTypeController,
                  decoration: InputDecoration(labelText: 'Room Type'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the room type';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _statusController,
                  decoration: InputDecoration(labelText: 'Status'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the status';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Create a map representing the updated room data
                        Map<String, dynamic> roomData = {
                          'roomId': _roomIdController.text,
                          'roomNumber': _roomNumberController.text,
                          'capacity': _capacityController.text,
                          'roomType': _roomTypeController.text,
                          'status': _statusController.text,
                        };

                        try {
                          // Update the room data in Firebase Firestore
                          await FirebaseFirestore.instance
                              .collection('Rooms')
                              .doc(widget.room.id)
                              .update(roomData);

                          // If the room is successfully updated, show a snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Room updated successfully'),
                            ),
                          );
                        } catch (error) {
                          // Handle any errors that occur during updating the room
                          print('Error updating room: $error');
                          // Optionally, you can show a snackbar or dialog to inform the user about the error
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating room: $error'),
                            ),
                          );
                        }
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xffB81736),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                      ),
                    ),
                    child: Text(
                      'Update Room',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
