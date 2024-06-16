import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookReservationHistory extends StatefulWidget {
  @override
  _BookReservationHistoryState createState() => _BookReservationHistoryState();
}

class _BookReservationHistoryState extends State<BookReservationHistory> {
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<String> _getBookTitle(String bookId) async {
    DocumentSnapshot bookSnapshot =
        await FirebaseFirestore.instance.collection('Book').doc(bookId).get();
    var bookData = bookSnapshot.data() as Map<String, dynamic>?;
    return bookData?['title'] ?? 'Unknown Book';
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return '${date.year}-${date.month}-${date.day} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteBooking(String reservationId, String bookId) async {
    // Remove book reservation
    await FirebaseFirestore.instance
        .collection('bookReservations')
        .doc(reservationId)
        .delete();

    // Update book status
    await FirebaseFirestore.instance
        .collection('Book')
        .doc(bookId)
        .update({'status': 'Available'});

    // Delete notification
    await _deleteNotification(bookId);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Book reservation cancelled successfully'),
    ));
  }

  Future<void> _deleteNotification(String bookId) async {
    CollectionReference notifications =
        FirebaseFirestore.instance.collection('Notifications');

    QuerySnapshot notificationSnapshot = await notifications
        .where('userId', isEqualTo: userId)
        .where('itemId', isEqualTo: bookId)
        .get();

    for (QueryDocumentSnapshot doc in notificationSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  bool _isOverdue(DateTime borrowDate) {
    DateTime returnDate = borrowDate.add(Duration(days: 14));
    return DateTime.now().isAfter(returnDate);
  }

  Widget _buildReservationCard(String reservationId, String bookTitle,
      DateTime borrowDate, String bookId) {
    bool isOverdue = _isOverdue(borrowDate);

    return GestureDetector(
      onTap: () {
        if (isOverdue) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Cancellation is blocked. The book return is overdue by ${DateTime.now().difference(borrowDate.add(Duration(days: 14))).inDays} days.'),
          ));
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: ListTile(
          contentPadding: const EdgeInsets.all(15.0),
          title: Text(
            bookTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            'Borrowed on: ${_formatDate(Timestamp.fromDate(borrowDate))}',
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.black54,
            ),
          ),
          trailing: isOverdue
              ? Icon(Icons.lock, color: Colors.red)
              : IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _deleteBooking(reservationId, bookId);
                  },
                ),
          tileColor: isOverdue ? Colors.red.shade100 : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookReservations')
          .where('userId', isEqualTo: userId)
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

        int reservationCount = snapshot.data!.docs.length;

        return Column(
          children: [
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: reservationCount,
                itemBuilder: (context, index) {
                  var reservation = snapshot.data!.docs[index];
                  DateTime borrowDate =
                      (reservation['date'] as Timestamp).toDate();
                  return FutureBuilder<String>(
                    future: _getBookTitle(reservation['bookId']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(
                          title: Text('Loading...'),
                        );
                      }
                      return _buildReservationCard(
                        reservation.id,
                        snapshot.data!,
                        borrowDate,
                        reservation['bookId'],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
