import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:library_app/api/firebase_api.dart';
import 'package:library_app/student/book/bookliststudent.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'auth/welcomeScreen.dart';
import 'auth/loginScreen.dart';
import 'auth/regScreen.dart';
import 'auth/logoutScreen.dart';
import 'student/homePageScreen.dart';
import 'auth/forgotpasswordScreen.dart';
import 'student/userprofileScreen.dart';
import 'librarian/librarianHomePage.dart';
import 'student/roomreservation/reservationRoomList.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseApi().initNotifications();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (kDebugMode) {
    print('Permission granted: ${settings.authorizationStatus}');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTM Library Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const welcomeScreen(),
        '/login': (context) => const loginScreen(),
        '/register': (context) => const RegScreen(),
        '/logout': (context) => const LogoutScreen(),
        '/home': (context) => HomePage(),
        '/forgotPassword': (context) => const forgotpasswordscreen(),
        '/userProfile': (context) => const UserProfileScreen(),
        '/librarian': (context) => const LibrarianHomePage(),
        '/booklistst': (context) => const BookListStudent(),
        '/reservationRoomList': (context) => const ReserveRoomList(),
      },
    );
  }
}
