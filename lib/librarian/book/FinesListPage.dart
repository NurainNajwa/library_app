import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FinesListPage extends StatefulWidget {
  const FinesListPage({Key? key}) : super(key: key);

  @override
  _FinesListPageState createState() => _FinesListPageState();
}

class _FinesListPageState extends State<FinesListPage> {
  @override
  void initState() {
    super.initState();
    _calculateFines();
  }

  Future<void> _calculateFines() async {
    final now = DateTime.now();
    final overdueLimit = Duration(days: 14);

    QuerySnapshot reservationsSnapshot =
        await FirebaseFirestore.instance.collection('bookReservations').get();

    for (var doc in reservationsSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      var borrowTimestamp = data['date'];
      String userId = data['userId'];
      String bookId = data['bookId'];

      if (borrowTimestamp != null) {
        DateTime borrowDate = (borrowTimestamp as Timestamp).toDate();
        Duration overdueDuration = now.difference(borrowDate) - overdueLimit;

        if (overdueDuration > Duration.zero) {
          int daysLate = overdueDuration.inDays;
          double fineAmount = daysLate * 1.0; // RM1 per day late

          // Check if fine already exists
          QuerySnapshot fineSnapshot = await FirebaseFirestore.instance
              .collection('fines')
              .where('userId', isEqualTo: userId)
              .where('bookId', isEqualTo: bookId)
              .get();

          if (fineSnapshot.docs.isEmpty) {
            await FirebaseFirestore.instance.collection('fines').add({
              'userId': userId,
              'bookId': bookId,
              'borrowDate': borrowDate,
              'dueDate': borrowDate.add(overdueLimit),
              'fineAmount': fineAmount,
            });
          } else {
            // Update existing fine amount
            DocumentSnapshot fineDoc = fineSnapshot.docs.first;
            await fineDoc.reference.update({
              'fineAmount': fineAmount,
            });
          }

          await FirebaseFirestore.instance.collection('Notifications').add({
            'userId': userId,
            'type': 'book',
            'itemId': doc.id,
            'date': Timestamp.now(),
            'status': 'overdue',
          });
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFines() async {
    try {
      QuerySnapshot finesSnapshot =
          await FirebaseFirestore.instance.collection('fines').get();

      List<Map<String, dynamic>> finesList = [];

      for (var doc in finesSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String userId = data['userId'] ?? '';
        String bookId = data['bookId'] ?? '';
        var borrowTimestamp = data['borrowDate'];

        if (borrowTimestamp == null || userId.isEmpty || bookId.isEmpty) {
          print('Missing data for document: ${doc.id}');
          continue;
        }

        DateTime borrowDate;
        if (borrowTimestamp is Timestamp) {
          borrowDate = borrowTimestamp.toDate();
        } else {
          print('Invalid timestamp format for document: ${doc.id}');
          continue;
        }

        finesList.add({
          'userId': userId,
          'fineAmount': data['fineAmount'],
          'bookId': bookId,
          'borrowDate': borrowDate,
        });
      }

      return finesList;
    } catch (e) {
      print('Error fetching fines: $e');
      rethrow;
    }
  }

  Future<String> _getUserName(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Student')
          .doc(userId)
          .get();
      var userData = userSnapshot.data() as Map<String, dynamic>?;
      return userData?['name'] ?? 'Unknown User';
    } catch (e) {
      print('Error fetching user name for $userId: $e');
      return 'Unknown User';
    }
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

  Future<void> _clearFines(String userId, String bookId) async {
    try {
      QuerySnapshot fineSnapshot = await FirebaseFirestore.instance
          .collection('fines')
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .get();

      if (fineSnapshot.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('fines')
            .doc(fineSnapshot.docs.first.id)
            .delete();
      }

      QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
          .collection('bookReservations')
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .get();

      if (reservationSnapshot.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('bookReservations')
            .doc(reservationSnapshot.docs.first.id)
            .delete();
      }

      print(
          'Fines and reservation cleared for userId: $userId, bookId: $bookId');
    } catch (e) {
      print('Error clearing fines: $e');
    }
  }

  void _showClearFinesDialog(
      BuildContext context, String userId, String bookId, double fineAmount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear Fines'),
          content: Text(
              'Are you sure the user has returned the book and paid the fine of MYR $fineAmount?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Clear Fines'),
              onPressed: () {
                _clearFines(userId, bookId).then((_) {
                  setState(() {});
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fines List'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 122, 24, 17),
                Color.fromARGB(255, 21, 1, 3)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchFines(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error in FutureBuilder: ${snapshot.error}');
            return const Center(child: Text('Error fetching data'));
          }

          List<Map<String, dynamic>> fines = snapshot.data ?? [];

          if (fines.isEmpty) {
            return const Center(child: Text('No fines found'));
          }

          return ListView.builder(
            itemCount: fines.length,
            itemBuilder: (context, index) {
              var fine = fines[index];
              String userId = fine['userId'];
              double fineAmount = fine['fineAmount'];
              String bookId = fine['bookId'];
              DateTime borrowDate = fine['borrowDate'];

              return FutureBuilder<List<String>>(
                future: Future.wait([
                  _getUserName(userId),
                  _getBookTitle(bookId),
                ]),
                builder: (context, userBookSnapshot) {
                  if (userBookSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: const Text('Loading...'),
                    );
                  }

                  if (userBookSnapshot.hasError) {
                    print(
                        'Error in nested FutureBuilder: ${userBookSnapshot.error}');
                    return ListTile(
                      leading: CircleAvatar(child: Icon(Icons.error)),
                      title: const Text('Error loading user/book info'),
                    );
                  }

                  String userName = userBookSnapshot.data?[0] ?? 'Unknown User';
                  String bookTitle =
                      userBookSnapshot.data?[1] ?? 'Unknown Book';
                  int daysLate =
                      DateTime.now().difference(borrowDate).inDays - 14;
                  DateTime dueDate = borrowDate.add(Duration(days: 14));

                  return Card(
                    elevation: 3,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 184, 18, 46),
                        child: Text(userName[0],
                            style: TextStyle(color: Colors.white)),
                      ),
                      title: Text(userName),
                      subtitle: Text(
                        'Fine: MYR $fineAmount\nBook: $bookTitle\nDays Late: $daysLate\nDue Date: ${dueDate.year}-${dueDate.month}-${dueDate.day}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () {
                          _showClearFinesDialog(
                              context, userId, bookId, fineAmount);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
