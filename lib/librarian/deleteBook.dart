import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteBookPage extends StatelessWidget {
  final DocumentSnapshot book;

  const DeleteBookPage({Key? key, required this.book}) : super(key: key);

  Future<void> _deleteBook(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('Book').doc(book.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book deleted successfully')),
      );
      // After deleting the book, navigate back to the previous page
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete book: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Book'),
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Are you sure you want to delete the book "${book['title']}"?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _deleteBook(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 158, 55, 47),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete Book',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
