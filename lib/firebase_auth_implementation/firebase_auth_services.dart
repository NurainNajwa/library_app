import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseAuthServices {
  FirebaseAuth _auth = FirebaseAuth.instance;

  // Constructor, not used for Firebase initialization
  FirebaseAuthServices();

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      print("Error occurred during sign up: ${e.toString()}");
      throw FirebaseAuthException(
          message: 'Error occurred during sign up', code: 'signup_error');
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      print("Error occurred during sign in: ${e.toString()}");
      throw FirebaseAuthException(
          message: 'Error occurred during sign in', code: 'signin_error');
    }
  }
}

void main() async {
  // Initialize Firebase outside the class
  await Firebase.initializeApp();
  // Use your FirebaseAuthServices class here
}
