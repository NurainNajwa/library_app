import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinesListPage extends StatelessWidget {
  const FinesListPage({Key? key}) : super(key: key);

  // Fetch fines and related data
  Future<List<Map<String, dynamic>>> _fetchFines() async {
    try {
      QuerySnapshot finesSnapshot =
          await FirebaseFirestore.instance.collection('fines').get();

      List<Map<String, dynamic>> finesList = [];

      for (var doc in finesSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String userId = data['userId'];
        double fineAmount = (data['fineAmount'] as num)
            .toDouble(); // Ensure fineAmount is treated as double
        String bookId = data['bookId']; // bookId from fines collection

        finesList.add({
          'userId': userId,
          'fineAmount': fineAmount,
          'bookId': bookId,
        });
      }

      return finesList;
    } catch (e) {
      print('Error fetching fines: $e');
      rethrow;
    }
  }

  // Get user's name from the 'Student' collection
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

  // Get book title from the 'Books' collection using the bookId from the fines collection
  Future<String> _getBookTitle(String bookId) async {
    try {
      QuerySnapshot bookSnapshot = await FirebaseFirestore.instance
          .collection('Book')
          .where('bookid',
              isEqualTo: bookId) // Use 'bookid' from Books collection
          .get();

      if (bookSnapshot.docs.isNotEmpty) {
        var bookData = bookSnapshot.docs.first.data() as Map<String, dynamic>;
        return bookData['title'] ?? 'Unknown Title';
      } else {
        return 'Unknown Title';
      }
    } catch (e) {
      print('Error fetching book title for $bookId: $e');
      return 'Unknown Title';
    }
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
                      subtitle: Text('Fine: MYR $fineAmount\nBook: $bookTitle'),
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
