import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BookTabs extends StatefulWidget {
  final String bookID;

  BookTabs({Key? key, required this.bookID}) : super(key: key);

  @override
  State<BookTabs> createState() => _BookTabsState();
}

class _BookTabsState extends State<BookTabs> {
  late String borrowerID;

  @override
  void initState() {
    super.initState();
    borrowerID = FirebaseAuth.instance.currentUser!.uid;
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
      // Default to 'Complete' tab for 'Overdue' status
      firestoreStatus = 'Completed';
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Book')
          .where('userid', isEqualTo: borrowerID)
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
}
