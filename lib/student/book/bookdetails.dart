import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookDetails extends StatefulWidget {
  final String bookid;

  const BookDetails({Key? key, required this.bookid}) : super(key: key);

  @override
  _BookDetailsState createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  late Future<DocumentSnapshot> _bookDetails;
  late Future<QuerySnapshot> _reservationDetails;
  late String borrowerId;

  @override
  void initState() {
    super.initState();
    _bookDetails = getBookDetails(widget.bookid);
    _reservationDetails = getReservationDetails(widget.bookid);
    borrowerId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book Details',
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
                Color(0xffB81736),
                Color(0xff281537),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _bookDetails,
        builder: (context, bookSnapshot) {
          if (bookSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!bookSnapshot.hasData) {
            return Center(child: Text('Error fetching book data'));
          }

          final bookData = bookSnapshot.data!;

          return FutureBuilder<QuerySnapshot>(
            future: _reservationDetails,
            builder: (context, reservationSnapshot) {
              if (reservationSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!reservationSnapshot.hasData) {
                return Center(child: Text('Error fetching reservation data'));
              }

              final reservations = reservationSnapshot.data!.docs;
              bool isBorrowedByCurrentUser = reservations.any(
                (doc) => doc['userId'] == borrowerId,
              );

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Author: ${bookData['author']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Title: ${bookData['title']}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Description: ${bookData['description']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Genre: ${bookData['genre']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Publication Date: ${bookData['publication_date']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Status: ${bookData['status']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: bookData['status'] == 'Available'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    SizedBox(height: 16),
                    if (bookData['status'] == 'Available')
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            await _borrowBook(bookSnapshot.data!.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(
                                121, 37, 65, 1), // Background color
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // Rounded corners
                            ),
                          ),
                          child: Text(
                            'Borrow Book',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else if (isBorrowedByCurrentUser)
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            await _cancelBook(bookSnapshot.data!.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Background color
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // Rounded corners
                            ),
                          ),
                          child: Text(
                            'Cancel Book',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<DocumentSnapshot> getBookDetails(String bookId) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('Book').doc(bookId).get();
    return snapshot;
  }

  Future<QuerySnapshot> getReservationDetails(String bookId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('bookReservations')
        .where('bookId', isEqualTo: bookId)
        .get();
    return snapshot;
  }

  Future<void> _borrowBook(String bookId) async {
    DocumentReference bookRef =
        FirebaseFirestore.instance.collection('Book').doc(bookId);

    await bookRef.update({'status': 'Booked'});

    CollectionReference bookReservations =
        FirebaseFirestore.instance.collection('bookReservations');

    await bookReservations.add({
      'bookId': bookId,
      'userId': borrowerId,
      'date': Timestamp.now(),
    });

    // Add notification
    CollectionReference notifications =
        FirebaseFirestore.instance.collection('Notifications');

    DateTime notificationDate =
        DateTime.now().add(Duration(days: 14)); // Return date
    await notifications.add({
      'userId': borrowerId,
      'type': 'book',
      'itemId': bookId,
      'date': Timestamp.fromDate(notificationDate),
      'status': 'upcoming',
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Book borrowed successfully'),
    ));
  }

  Future<void> _cancelBook(String bookId) async {
  DocumentReference bookRef =
      FirebaseFirestore.instance.collection('Book').doc(bookId);

  // Check if the user has fines for this book
  bool hasFines = await checkFines(bookId);

  if (hasFines) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('You cannot cancel the reservation because fines are charged.'),
    ));
    return; // Exit the function if fines exist
  }

  // Proceed with cancellation if no fines are found
  await bookRef.update({'status': 'Available'});

  // Remove book reservation
  CollectionReference bookReservations =
      FirebaseFirestore.instance.collection('bookReservations');

  QuerySnapshot reservationSnapshot = await bookReservations
      .where('bookId', isEqualTo: bookId)
      .where('userId', isEqualTo: borrowerId)
      .get();

  for (QueryDocumentSnapshot doc in reservationSnapshot.docs) {
    await doc.reference.delete();
  }

  // Delete notification
  await deleteNotification(bookId);

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('Book reservation cancelled successfully'),
  ));
}

Future<bool> checkFines(String bookId) async {
  // Query fines collection or wherever fines are stored
  CollectionReference finesRef =
      FirebaseFirestore.instance.collection('fines');

  QuerySnapshot finesSnapshot = await finesRef
      .where('bookId', isEqualTo: bookId)
      .where('userId', isEqualTo: borrowerId)
      .get();

  return finesSnapshot.docs.isNotEmpty; // Return true if fines exist, false otherwise
}


  Future<void> deleteNotification(String bookId) async {
    CollectionReference notifications =
        FirebaseFirestore.instance.collection('Notifications');
    QuerySnapshot notificationSnapshot = await notifications
        .where('userId', isEqualTo: borrowerId)
        .where('itemId', isEqualTo: bookId)
        .get();

    for (QueryDocumentSnapshot doc in notificationSnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
