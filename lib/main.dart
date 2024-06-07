import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:library_app/student/book/bookliststudent.dart';
import 'auth/welcomeScreen.dart';
import 'auth/loginScreen.dart';
import 'auth/regScreen.dart';
import 'auth/logoutScreen.dart';
import 'student/homePageScreen.dart';
import 'auth/forgotpasswordScreen.dart';
import 'student/userprofileScreen.dart';
import 'librarian/librarianHomePage.dart';
import 'student/roomreservation/reservationRoomList.dart';
import 'student/bookingHistory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: 'AIzaSyD7hIRJcEwhaPM7jycmzrCXl-wjWyIsFy0',
    appId: '1:954659947232:android:74c8e9687e70db16c60685',
    messagingSenderId: 'sendid',
    projectId: 'library-app-502af',
    storageBucket: 'myapp-b9yt18.appspot.com',
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTM Library Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => welcomeScreen(),
        '/login': (context) => loginScreen(),
        '/register': (context) => RegScreen(),
        '/logout': (context) => LogoutScreen(),
        '/home': (context) => HomePage(),
        '/forgotPassword': (context) => forgotpasswordscreen(),
        '/userProfile': (context) => UserProfileScreen(),
        '/librarian': (context) => LibrarianHomePage(),
        '/booklistst': (context) => BookListStudent(),
        '/reservationRoomList': (context) => ReserveRoomList(),
        '/bookingHistory': (context) => BookingHistory(),
      },
    );
  }
}
