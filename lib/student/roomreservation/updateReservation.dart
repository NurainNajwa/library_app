import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateReservation extends StatefulWidget {
  final DocumentSnapshot reservation;

  UpdateReservation({required this.reservation});

  @override
  _UpdateReservationState createState() => _UpdateReservationState();
}

class _UpdateReservationState extends State<UpdateReservation> {
  final _formKey = GlobalKey<FormState>();
  late String selectedRoom;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final List<String> rooms = ['Room 1', 'Room 2', 'Room 3', 'Room 4'];
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        selectedRoom = widget.reservation['room'];
        selectedDate = (widget.reservation['date'] as Timestamp).toDate();
        selectedTime = TimeOfDay.fromDateTime(selectedDate!);
        _dateController.text = selectedDate!.toString().split(' ')[0];
        _timeController.text = selectedTime!.format(context);
      });
    });
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
          'Update Reservation',
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
                  readOnly: true,
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Select Date',
                    hintText: 'Tap to select date',
                  ),
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
                  readOnly: true,
                  controller: _timeController,
                  decoration: InputDecoration(
                    labelText: 'Select Time',
                    hintText: 'Tap to select time',
                  ),
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
                        Map<String, dynamic> updatedReservationData = {
                          'room': selectedRoom,
                          'date': Timestamp.fromDate(DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          )),
                        };

                        try {
                          // Update the reservation data in Firebase Firestore
                          await FirebaseFirestore.instance
                              .collection('Reservations')
                              .doc(widget.reservation.id)
                              .update(updatedReservationData);

                          // If the reservation is successfully updated, show a snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Reservation updated successfully'),
                            ),
                          );

                          // Navigate back to the previous screen
                          Navigator.pop(context);
                        } catch (error) {
                          // Handle any errors that occur during updating the reservation
                          print('Error updating reservation: $error');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Error updating reservation: $error'),
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
                      'Update Reservation',
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
