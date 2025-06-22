import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // --- Authentication Methods ---
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      } else {
        throw Exception('Authentication failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unknown error occurred during sign-in: $e');
    }
  }

  Future<UserCredential> createUserWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      } else {
        throw Exception('User creation failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unknown error occurred during user creation: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // --- Realtime Database Methods ---

  // Stream to listen to elephant locations
  Stream<DatabaseEvent> getElephantLocationsStream() {
    return _database.ref().child('elephant_locations').onValue;
  }

  // Get a single user's data from Realtime DB
  Future<DataSnapshot> getUserData(String uid) async {
    return _database.ref().child('users').child(uid).get();
  }

  // Set user data in Realtime DB
  Future<void> setUserData(String uid, Map<String, dynamic> data) async {
    await _database.ref().child('users').child(uid).set(data);
  }

  // Delete user data from Realtime DB
  Future<void> deleteUserData(String uid) async {
    await _database.ref().child('users').child(uid).remove();
  }

  // Get all users from Realtime DB (for admin panel)
  Future<DataSnapshot> getAllUsersData() async {
    return _database.ref().child('users').get();
  }
}