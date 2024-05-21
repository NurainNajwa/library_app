import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Updateroom extends StatefulWidget {
  final DocumentSnapshot? room;

  Updateroom({this.room});

  @override
  _UpdateroomState createState() => _UpdateroomState();
}

class _UpdateroomState extends State<Updateroom> {
  final _formKey = GlobalKey<FormState>();
  String selectedRoom = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final List<String> rooms = ['Room 1', 'Room 2', 'Room 3', 'Room 4'];

  @override
  void initState() {
    super.initState();
    selectedRoom = widget.room?['room'] ?? '';
    selectedDate = (widget.room?['date'] as Timestamp?)?.toDate();
    selectedTime = TimeOfDay.fromDateTime(
      (widget.room?['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update room',
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
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Select Room'),
                  value: selectedRoom,
                  items: rooms.map((String room) {
                    return DropdownMenuItem<String>(
                      value: room,
                      child: Text(room),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRoom = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a room';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Select Date',
                    hintText: selectedDate != null
                        ? '${selectedDate!.toLocal()}'.split(' ')[0]
                        : 'Tap to select date',
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (selectedDate == null) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Select Time',
                    hintText: selectedTime != null
                        ? selectedTime!.format(context)
                        : 'Tap to select time',
                  ),
                  readOnly: true,
                  onTap: () => _selectTime(context),
                  validator: (value) {
                    if (selectedTime == null) {
                      return 'Please select a time';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        // Create a map representing the room data
                        Map<String, dynamic> updatedroomData = {
                          'room': selectedRoom,
                          'date': DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          ),
                        };

                        try {
                          // Update the room data in Firebase Firestore
                          await FirebaseFirestore.instance
                              .collection('rooms')
                              .doc(widget.room!.id)
                              .update(updatedroomData);

                          // If the room is successfully updated, show a snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Room updated successfully'),
                            ),
                          );

                          // Navigate back to the previous screen
                          Navigator.pop(context);
                        } catch (error) {
                          // Handle any errors that occur during updating the room
                          print('Error updating room: $error');
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
