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
  late String borrowerId;

  @override
  void initState() {
    super.initState();
    _bookDetails = getBookDetails(widget.bookid);
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
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Error fetching data'));
          }

          final bookData = snapshot.data!;

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
                        await _borrowBook(snapshot.data!.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color.fromRGBO(121, 37, 65, 1), // Background color
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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
                else
                  Text("Sorry, this book is already booked"),
              ],
            ),
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

  Future<void> _borrowBook(String bookId) async {
    DocumentReference bookRef =
        FirebaseFirestore.instance.collection('Book').doc(bookId);

    await bookRef.update({'status': 'Booked'});

    CollectionReference borrowedBooks =
        FirebaseFirestore.instance.collection('borrowedBooks');

    await borrowedBooks.add({
      'bookid': bookId,
      'userid': borrowerId,
      'borrowdate': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Book borrowed successfully'),
    ));
  }
}
