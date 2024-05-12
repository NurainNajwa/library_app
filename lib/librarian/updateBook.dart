import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateBook extends StatefulWidget {
  final DocumentSnapshot book;

  const UpdateBook({Key? key, required this.book}) : super(key: key);

  @override
  _UpdateBookState createState() => _UpdateBookState();
}

class _UpdateBookState extends State<UpdateBook> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;
  late TextEditingController _genreController;
  late TextEditingController _publicationDateController;

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with empty values or retrieve existing values if available
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _descriptionController = TextEditingController();
    _genreController = TextEditingController();
    _publicationDateController = TextEditingController();
    // Load existing book data if available
    loadBookData();
  }

  @override
  void dispose() {
    // Dispose text controllers when the widget is disposed to avoid memory leaks
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _genreController.dispose();
    _publicationDateController.dispose();
    super.dispose();
  }

  Future<void> loadBookData() async {
    try {
      // Retrieve existing book data from Firebase Firestore based on bookId
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('Book')
          .doc(widget.book.id)
          .get();
      if (documentSnapshot.exists) {
        // Populate text controllers with existing book data
        var data = documentSnapshot.data() as Map<String, dynamic>;
        _titleController.text = data['title'] ?? '';
        _authorController.text = data['author'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _genreController.text = data['genre'] ?? '';
        _publicationDateController.text = data['publication_date'] ?? '';
      }
    } catch (error) {
      print('Error loading book data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Book',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _authorController,
                  decoration: InputDecoration(labelText: 'Author'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an author';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _genreController,
                  decoration: InputDecoration(labelText: 'Genre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter genre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _publicationDateController,
                  decoration: InputDecoration(labelText: 'Publication Date'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter publication date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Create a map representing the updated book data
                        Map<String, dynamic> bookData = {
                          'title': _titleController.text,
                          'author': _authorController.text,
                          'description': _descriptionController.text,
                          'genre': _genreController.text,
                          'publication_date': _publicationDateController.text,
                        };

                        try {
                          // Update the book data in Firebase Firestore
                          await FirebaseFirestore.instance
                              .collection('Book')
                              .doc(widget.book.id)
                              .update(bookData);

                          // If the book is successfully updated, show a snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Book updated successfully'),
                            ),
                          );
                        } catch (error) {
                          // Handle any errors that occur during updating the book
                          print('Error updating book: $error');
                          // Optionally, you can show a snackbar or dialog to inform the user about the error
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating book: $error'),
                            ),
                          );
                        }
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xffB81736),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                      ),
                    ),
                    child: Text(
                      'Update Book',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
