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
        .collection('Reservations')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      DateTime now = DateTime.now();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['date'] != null) {
          DateTime reservationDate = (data['date'] as Timestamp).toDate();
          Duration difference = reservationDate.difference(now);

          if (difference.inDays > 0 && difference.inDays <= 7) {
            _showNotification('Upcoming Room Reservation',
                'Your room reservation is in ${difference.inDays} days');
            _addNotification('room', doc.id, reservationDate);
          }
        }
      }
    });

    FirebaseFirestore.instance
        .collection('bookReservations')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      DateTime now = DateTime.now();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['date'] != null) {
          DateTime borrowDate = (data['date'] as Timestamp).toDate();
          DateTime returnDate = borrowDate.add(Duration(days: 14));
          Duration difference = returnDate.difference(now);

          if (difference.inDays > 0 && difference.inDays <= 7) {
            _showNotification('Upcoming Book Return',
                'Your book is due in ${difference.inDays} days');
            _addNotification('book', doc.id, returnDate);
          }
        }
      }
    });
  }

  void _addNotification(String type, String itemId, DateTime date) async {
    CollectionReference notifications =
        FirebaseFirestore.instance.collection('Notifications');

    await notifications.add({
      'userId': userId,
      'type': type,
      'itemId': itemId,
      'date': Timestamp.fromDate(date),
      'status': 'upcoming',
    });
  }

  Future<void> _deleteNotification(String itemId) async {
    CollectionReference notifications =
        FirebaseFirestore.instance.collection('Notifications');

    QuerySnapshot notificationSnapshot = await notifications
        .where('userId', isEqualTo: userId)
        .where('itemId', isEqualTo: itemId)
        .get();
    for (QueryDocumentSnapshot doc in notificationSnapshot.docs) {
      await doc.reference.delete();
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
            .where('status', isEqualTo: 'upcoming')
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
            int daysLeft = date.difference(DateTime.now()).inDays;
            if (data['type'] == 'book') {
              notifications.add(
                FutureBuilder<String>(
                  future: _getBookTitle(data['itemId']),
                  builder: (context, bookSnapshot) {
                    if (bookSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildNotificationCard(
                          doc.id, 'Loading...', '', Icons.book, Colors.orange);
                    }
                    return _buildNotificationCard(
                      doc.id,
                      'Book Return Reminder: ${bookSnapshot.data}',
                      'Due in $daysLeft days',
                      Icons.book,
                      Colors.orange,
                    );
                  },
                ),
              );
            } else if (data['type'] == 'room') {
              notifications.add(
                _buildNotificationCard(
                  doc.id,
                  'Upcoming Room Reservation',
                  'Reservation in $daysLeft days',
                  Icons.event,
                  Colors.blue,
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
