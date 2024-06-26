import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FineHistoryPage extends StatefulWidget {
  final String userId;

  const FineHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  _FineHistoryPageState createState() => _FineHistoryPageState();
}

class _FineHistoryPageState extends State<FineHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fine History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        backgroundColor: const Color(0xffB81736),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Fine Section
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              child: FutureBuilder<double>(
                future: _calculateTotalFines(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  double totalFines = snapshot.data ?? 0.0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Fine:',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        'MYR ${totalFines.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Book Details
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('fines')
                    .where('userId', isEqualTo: widget.userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error fetching data',
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No fines found',
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var fine = snapshot.data!.docs[index];
                      Timestamp borrowDate = fine['borrowDate'];
                      Timestamp dueDate = fine['dueDate'];
                      int lateDays = _calculateLateDays(borrowDate, dueDate);

                      return FutureBuilder<String>(
                        future: _getBookTitle(fine['bookId']),
                        builder: (context, bookSnapshot) {
                          if (bookSnapshot.connectionState == ConnectionState.waiting) {
                            return ListTile(
                              title: Text('Loading...'),
                            );
                          }

                          return Container(
                            margin: EdgeInsets.only(bottom: 15.0),
                            padding: EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Book: ${bookSnapshot.data}',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  'Fine Amount: MYR ${fine['fineAmount']}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  'Borrowed on: ${_formatDate(borrowDate)}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  'Due Date: ${_formatDate(dueDate)}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  'Late Return Days: $lateDays',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: lateDays > 0 ? Colors.red : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<double> _calculateTotalFines() async {
    QuerySnapshot finesSnapshot = await FirebaseFirestore.instance
        .collection('fines')
        .where('userId', isEqualTo: widget.userId)
        .get();

    double totalFines = 0.0;
    for (var doc in finesSnapshot.docs) {
      totalFines += doc['fineAmount'];
    }
    return totalFines;
  }

  Future<String> _getBookTitle(String bookId) async {
    try {
      DocumentSnapshot bookSnapshot =
          await FirebaseFirestore.instance.collection('Book').doc(bookId).get();
      var bookData = bookSnapshot.data() as Map<String, dynamic>?;
      return bookData?['title'] ?? 'Unknown Title';
    } catch (e) {
        print('Error fetching book title for $bookId: $e');
        return 'Unknown Title';
    }
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return '${date.year}-${date.month}-${date.day}';
  }

  int _calculateLateDays(Timestamp borrowDate, Timestamp dueDate) {
    DateTime now = DateTime.now();
    DateTime dueDateTime = dueDate.toDate();
    return now.isAfter(dueDateTime)
        ? now.difference(dueDateTime).inDays
        : 0;
  }
}
