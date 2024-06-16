import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late String userId;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    _initializeNotifications();
    _listenForChanges();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '1:954659947232:android:159b9b44324891b8c60685',
      'Library-app',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void _listenForChanges() {
    FirebaseFirestore.instance
        .collection('bookReservations')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) async {
      DateTime now = DateTime.now();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var borrowTimestamp = data['date'];
        String reservationId = doc.id;
        String bookId = data['bookId'] ?? 'Unknown Book';

        if (borrowTimestamp != null) {
          DateTime borrowDate = (borrowTimestamp as Timestamp).toDate();
          DateTime returnDate = borrowDate.add(Duration(days: 14));
          Duration difference = returnDate.difference(now);

          int daysLeft = difference.inDays;
          String status = daysLeft < 0 ? 'overdue' : 'upcoming';

          await _updateOrCreateNotification(
              'book', reservationId, bookId, returnDate, status, daysLeft);
          if (daysLeft <= 7 && daysLeft >= 0) {
            _showNotification(
                'Upcoming Book Return', 'Your book is due in $daysLeft days');
          }
        }
      }
    });
  }

  Future<void> _updateOrCreateNotification(String type, String itemId,
      String bookId, DateTime date, String status, int daysLeft) async {
    CollectionReference notifications =
        FirebaseFirestore.instance.collection('Notifications');

    QuerySnapshot existingNotifications = await notifications
        .where('userId', isEqualTo: userId)
        .where('itemId', isEqualTo: itemId)
        .get();

    if (existingNotifications.docs.isEmpty) {
      // Add new notification
      await notifications.add({
        'userId': userId,
        'type': type,
        'itemId': itemId,
        'bookId': bookId,
        'date': Timestamp.fromDate(date),
        'status': status,
        'daysLeft': daysLeft,
      });
    } else {
      // Update existing notification
      var existingNotification = existingNotifications.docs.first;
      await notifications.doc(existingNotification.id).update({
        'date': Timestamp.fromDate(date),
        'status': status,
        'daysLeft': daysLeft,
      });
    }
  }

  Widget _buildNotificationCard(String notificationId, String title,
      String subtitle, IconData icon, Color iconColor) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 40),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 16.0, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getBookTitle(String bookId) async {
    DocumentSnapshot bookSnapshot =
        await FirebaseFirestore.instance.collection('Book').doc(bookId).get();
    var bookData = bookSnapshot.data() as Map<String, dynamic>?;
    return bookData?['title'] ?? 'Unknown Book';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Notifications')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: _buildNotificationCard('', 'No notifications', '',
                  Icons.notifications_none, Colors.grey),
            );
          }

          List<Widget> notifications = [];

          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            DateTime date = (data['date'] as Timestamp).toDate();
            int daysLeft = data['daysLeft'] ?? 0; // Default to 0 if null
            String status = data['status'];
            String bookId = data['bookId'] ?? 'Unknown Book';
            if (data['type'] == 'book') {
              notifications.add(
                FutureBuilder<String>(
                  future: _getBookTitle(bookId),
                  builder: (context, bookSnapshot) {
                    if (bookSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildNotificationCard(
                          doc.id, 'Loading...', '', Icons.book, Colors.orange);
                    }
                    if (bookSnapshot.hasData) {
                      String bookTitle = bookSnapshot.data!;
                      if (status == 'upcoming') {
                        return _buildNotificationCard(
                          doc.id,
                          'Book Return Reminder: $bookTitle',
                          'Due in $daysLeft days',
                          Icons.book,
                          Colors.orange,
                        );
                      } else if (status == 'overdue') {
                        return _buildNotificationCard(
                          doc.id,
                          'Book Return Reminder: $bookTitle',
                          'Overdue by ${-daysLeft} days',
                          Icons.book,
                          Colors.red,
                        );
                      }
                    }
                    return Container(); // Handle other cases
                  },
                ),
              );
            }
          }

          return ListView(
            children: notifications,
          );
        },
      ),
    );
  }
}
