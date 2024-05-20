import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRoom extends StatefulWidget {
  @override
  _AddRoomState createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {
  final _formKey = GlobalKey<FormState>();
  var capacity = '';
  var roomType = '';
  var roomId = '';
  var roomNumber = '';
  var status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Room',
          style: TextStyle(
            color: Colors.white, // Set the font color to white
            fontWeight: FontWeight.bold, // Set the font weight to bold
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
                  decoration: InputDecoration(labelText: 'Room ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a room ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    roomId = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Room Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a room number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    roomNumber = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Capacity'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the capacity';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    capacity = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Room Type'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the room type';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    roomType = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Status'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the status';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    status = value!;
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        // Create a map representing the room data
                        Map<String, dynamic> roomData = {
                          'roomId': roomId,
                          'roomNumber': roomNumber,
                          'capacity': capacity,
                          'roomType': roomType,
                          'status': status,
                        };

                        try {
                          // Add the room data to Firebase Firestore
                          await FirebaseFirestore.instance
                              .collection('Rooms')
                              .add(roomData);

                          // If the room is successfully added, show a snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Room added successfully'),
                            ),
                          );

                          // Clear the form fields
                          _formKey.currentState!.reset();
                        } catch (error) {
                          // Handle any errors that occur during adding the room
                          print('Error adding room: $error');
                          // Optionally, you can show a snackbar or dialog to inform the user about the error
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error adding room: $error'),
                            ),
                          );
                        }
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(
                            0xffB81736), // Set the button color same as app bar color
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ), // Set the button padding
                      ),
                    ),
                    child: Text(
                      'Add Room',
                      style: TextStyle(
                        color: Colors.white, // Set the font color to white
                        fontSize: 18, // Set the font size
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
