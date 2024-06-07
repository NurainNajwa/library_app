import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookTabs extends StatefulWidget {
  final String bookID;

  BookTabs({Key? key, required this.bookID}) : super(key: key);

  @override
  State<BookTabs> createState() => _BookTabsState();
}

class _BookTabsState extends State<BookTabs> {
  late String librarianID;

  @override
  void initState() {
    super.initState();
    librarianID = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Borrowed Books'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent('Pending'),
            _buildTabContent('Booked'),
            _buildTabContent('Completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String status) {
    String firestoreStatus;
    if (status == 'Pending') {
      firestoreStatus = 'Pending';
    } else if (status == 'Booked') {
      firestoreStatus = 'Booked';
    } else if (status == 'Completed') {
      firestoreStatus = 'Completed';
    } else {
      // Default to 'Booked' tab for 'Overdue' status
      firestoreStatus = 'Completed';
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Book')
          .where('status', isEqualTo: firestoreStatus)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<DocumentSnapshot> bookReservations = snapshot.data!.docs;
          return ListView.builder(
            itemCount: bookReservations.length,
            itemBuilder: (context, index) {
              var bookData = bookReservations[index];
              return ListTile(
                title: FutureBuilder<DocumentSnapshot>(
                  future: getBookDetails(bookData['bookid']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading...');
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      var book = snapshot.data!;
                      return Text(
                          'Title: ${book['title']}, Status: ${book['status']}');
                    }
                  },
                ),
                subtitle: FutureBuilder<DocumentSnapshot>(
                  future: getStudentDetails(bookData['userid']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Borrower: Loading...');
                    } else if (snapshot.hasError) {
                      return Text('Borrower: Error: ${snapshot.error}');
                    } else {
                      var borrower = snapshot.data!;
                      return Text('Borrower: ${borrower['name']}');
                    }
                  },
                ),
                trailing: status == 'Pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              _acceptBookRequest(bookData.id);
                            },
                            icon: Icon(Icons.check),
                          ),
                          IconButton(
                            onPressed: () {
                              _rejectBookRequest(bookData.id);
                            },
                            icon: Icon(Icons.close),
                          ),
                        ],
                      )
                    : status == 'Booked'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _acceptBookReturnRequest(bookData.id);
                                },
                                icon: Icon(Icons.check),
                              ),
                              IconButton(
                                onPressed: () {
                                  _rejectBookReturnRequest(bookData.id);
                                },
                                icon: Icon(Icons.close),
                              ),
                            ],
                          )
                        : status == 'Completed'
                            ? IconButton(
                                onPressed: () {
                                  _completeAvailable(bookData.id);
                                },
                                icon: Icon(Icons.check),
                              )
                            : null,
              );
            },
          );
        }
      },
    );
  }

  Future<DocumentSnapshot> getBookDetails(String bookid) async {
    return await FirebaseFirestore.instance
        .collection('Book')
        .doc(bookid)
        .get();
  }

  Future<DocumentSnapshot> getStudentDetails(String userid) async {
    return await FirebaseFirestore.instance
        .collection('Student')
        .doc(userid)
        .get();
  }

  Future<void> _acceptBookRequest(String bookID) async {
    await FirebaseFirestore.instance.collection('Book').doc(bookID).update({
      'status': 'Booked',
    });
  }

  Future<void> _rejectBookRequest(String bookID) async {
    await FirebaseFirestore.instance.collection('Book').doc(bookID).update({
      'status': 'Available',
    });
  }

  Future<void> _acceptBookReturnRequest(String bookID) async {
    await FirebaseFirestore.instance.collection('Book').doc(bookID).update({
      'status': 'Completed',
    });
  }

  Future<void> _rejectBookReturnRequest(String bookID) async {
    await FirebaseFirestore.instance.collection('Book').doc(bookID).update({
      'status': 'Overdue',
    });
  }

  Future<void> _completeAvailable(String bookID) async {
    await FirebaseFirestore.instance.collection('Book').doc(bookID).update({
      'status': 'Available',
    });
  }
}
