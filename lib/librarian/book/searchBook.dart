import 'package:cloud_firestore/cloud_firestore.dart';

class SearchBook {
  final CollectionReference _booksCollection =
      FirebaseFirestore.instance.collection('Book');

  Future<List<QueryDocumentSnapshot>> searchBooks(String query) async {
    var searchQuery = query.toLowerCase().trim();

    var books = await _booksCollection.get();
    var filteredBooks = books.docs.where((doc) {
      var title = doc['title'].toString().toLowerCase();
      var author = doc['author'].toString().toLowerCase();
      return title.contains(searchQuery) || author.contains(searchQuery);
    }).toList();

    return filteredBooks;
  }
}
