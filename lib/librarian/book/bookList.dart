import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:library_app/librarian/book/addBook.dart';
import 'deleteBook.dart';
import 'updateBook.dart';
import 'searchBook.dart'; // Import the searchBook.dart file

class BookList extends StatefulWidget {
  const BookList({Key? key}) : super(key: key);

  @override
  BookListState createState() => BookListState();
}

class BookListState extends State<BookList> {
  late CollectionReference _booksCollection;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late Future<List<QueryDocumentSnapshot>> _searchResults;

  @override
  void initState() {
    super.initState();
    _booksCollection = FirebaseFirestore.instance.collection('Book');
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
        _searchResults = SearchBook().searchBooks(_searchQuery);
      });
    });
    _searchResults = SearchBook().searchBooks('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Book List',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Books',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _searchQuery =
                          _searchController.text.trim().toLowerCase();
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _booksCollection.snapshots(),
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

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No books available'),
                  );
                }

                // Filter books based on search query
                var books = snapshot.data!.docs;
                if (_searchQuery.isNotEmpty) {
                  books = books.where((doc) {
                    var title = doc['title'].toString().toLowerCase();
                    var author = doc['author'].toString().toLowerCase();
                    return title.contains(_searchQuery) ||
                        author.contains(_searchQuery);
                  }).toList();
                }

                return ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    var book = books[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      child: ListTile(
                        title: Text(
                          book['title'].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          book['author'].toString(),
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black54,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                // Navigate to edit book page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UpdateBook(book: book),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DeleteBookPage(book: book),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigate to update book page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateBook(book: book),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => addBook(),
            ),
          );
        },
        backgroundColor: const Color(0xffB81736),
        child: const Icon(Icons.add),
      ),
    );
  }
}
