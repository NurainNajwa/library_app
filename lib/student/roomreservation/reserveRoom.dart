import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddReservation extends StatefulWidget {
  final DocumentSnapshot? room;

  AddReservation({this.room});

  @override
  _AddReservationState createState() => _AddReservationState();
}

class _AddReservationState extends State<AddReservation> {
  final _formKey = GlobalKey<FormState>();
  String selectedRoom = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final List<String> rooms = ['Room 1', 'Room 2', 'Room 3', 'Room 4'];
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      selectedRoom = widget.room!['name'];
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
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
        _dateController.text = '${selectedDate!.toLocal()}'.split(' ')[0];
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
        _timeController.text = selectedTime!.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Reservation',
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
                if (widget.room == null) ...[
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Select Room'),
                    value: selectedRoom.isNotEmpty ? selectedRoom : null,
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
                ],
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Select Date',
                    hintText: 'Tap to select date',
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
                  controller: _timeController,
                  decoration: InputDecoration(
                    labelText: 'Select Time',
                    hintText: 'Tap to select time',
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

                        // Create a map representing the reservation data
                        Map<String, dynamic> reservationData = {
                          'room': widget.room != null
                              ? widget.room!['name']
                              : selectedRoom,
                          'date': selectedDate,
                          'time': selectedTime?.format(context),
                        };

                        try {
                          // Add the reservation data to Firebase Firestore
                          await FirebaseFirestore.instance
                              .collection('Reservations')
                              .add(reservationData);

                          // If the reservation is successfully added, show a snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Reservation added successfully'),
                            ),
                          );

                          // Clear the form fields
                          setState(() {
                            if (widget.room == null) {
                              selectedRoom = '';
                            }
                            selectedDate = null;
                            selectedTime = null;
                            _dateController.clear();
                            _timeController.clear();
                          });
                        } catch (error) {
                          // Handle any errors that occur during adding the reservation
                          print('Error adding reservation: $error');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error adding reservation: $error'),
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
                      'Add Reservation',
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
