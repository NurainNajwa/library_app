import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Import FirebaseAuthServices if it's used here
import 'firebase_auth_implementation/firebase_auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const FirebaseOptions firebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyD7hIRJcEwhaPM7jycmzrCXl-wjWyIsFy0',
    appId: '1:954659947232:android:74c8e9687e70db16c60685',
    messagingSenderId: 'sendid',
    projectId: 'library-app-502af',
    storageBucket: 'myapp-b9yt18.appspot.com',
  );

  // Ensure Firebase is initialized only once
  await Firebase.initializeApp(
    options: firebaseOptions,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Initialize FirebaseAuthServices if it's used here
  final FirebaseAuthServices firebaseAuthServices = FirebaseAuthServices();

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
        '/userProfile': (context) => UserProfileScreenRoute(),
        '/librarian': (context) => LibrarianHomePage(),
        '/booklistst': (context) => BookListStudent(),
        '/reservationRoomList': (context) => ReserveRoomList(),
        '/bookingHistory': (context) => BookingHistory(),
      },
    );
  }
}

class UserProfileScreenRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the ModalRoute
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final userid = arguments['userid'];

    // Pass the extracted arguments to the UserProfileScreen
    return UserProfileScreen(userid: userid);
  }
}
