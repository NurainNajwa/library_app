import 'package:flutter/material.dart';
import 'book/bookReservationHistory.dart';
import 'roomReservation/roomReservationHistory.dart';

class BookingHistory extends StatefulWidget {
  const BookingHistory({Key? key}) : super(key: key);

  @override
  _BookingHistoryState createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    BookReservationHistory(),
    RoomReservationHistory(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Booking',
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.room),
            label: 'Rooms',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xffB81736),
        onTap: _onItemTapped,
      ),
    );
  }
}
