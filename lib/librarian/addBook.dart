import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class addBook extends StatefulWidget {
  @override
  _AddBookState createState() => _AddBookState();
}

class _AddBookState extends State<addBook> {
  final _formKey = GlobalKey<FormState>();
  var title = '';
  var author = '';
  var description = '';
  var genre = '';
  var publication_date = '';
  var bookid = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Book',
          style: TextStyle(
            color: Colors.white, // Set the font color to white
            fontWeight: FontWeight.bold, // Set the font weight to bold
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
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    title = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Author'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an author';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    author = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    description = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Genre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter genre';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    genre = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Publication Date'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter publication date';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    publication_date = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Book Id '),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter book id';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    bookid = value!;
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        // Create a map representing the book data
                        Map<String, dynamic> bookData = {
                          'title': title,
                          'author': author,
                          'description': description,
                          'genre': genre,
                          'publication_date': publication_date,
                          'bookid': bookid,
                        };

                        try {
                          // Add the book data to Firebase Firestore
                          await FirebaseFirestore.instance
                              .collection('Book')
                              .add(bookData);

                          // If the book is successfully added, show a snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Book added successfully'),
                            ),
                          );

                          // Clear the form fields
                          _formKey.currentState!.reset();
                        } catch (error) {
                          // Handle any errors that occur during adding the book
                          print('Error adding book: $error');
                          // Optionally, you can show a snackbar or dialog to inform the user about the error
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error adding book: $error'),
                            ),
                          );
                        }
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(
                            0xffB81736), // Set the button color same as app bar color
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ), // Set the button padding
                      ),
                    ),
                    child: Text(
                      'Add Book',
                      style: TextStyle(
                        color: Colors.white, // Set the font color to white
                        fontSize: 18, // Set the font size
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
