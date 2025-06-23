import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elephant_tracking_app/services/firebase_service.dart'; 
import 'package:elephant_tracking_app/models/user_app.dart';

class AuthController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserApp? _currentUser;

  UserApp? get currentUser => _currentUser;

  AuthController() {
    _firebaseService.authStateChanges.listen((user) async {
      if (user != null) {
        // Fetch user data from Realtime DB to get their role
        try {
          final userDataSnapshot = await _firebaseService.getUserData(user.uid);
          if (userDataSnapshot.exists) {
            _currentUser = UserApp.fromMap(
                userDataSnapshot.value as Map<dynamic, dynamic>, user.uid);
          } else {
            _currentUser = UserApp(uid: user.uid, email: user.email!, role: 'unknown');
          }
        } catch (e) {
          print("Error fetching user role: $e");
          _currentUser = UserApp(uid: user.uid, email: user.email!, role: 'unknown');
        }
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseService.signInWithEmailPassword(email, password);
      // The listener will update _currentUser and notify listeners
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
    } catch (e) {
      print("Error signing out: $e");
      throw e;
    }
  }

  Future<UserApp?> checkInitialAuthState() async {
    User? firebaseUser = _firebaseService.getCurrentUser();
    if (firebaseUser != null) {
      try {
        final userDataSnapshot = await _firebaseService.getUserData(firebaseUser.uid);
        if (userDataSnapshot.exists) {
          _currentUser = UserApp.fromMap(
              userDataSnapshot.value as Map<dynamic, dynamic>, firebaseUser.uid);
          return _currentUser;
        }
      } catch (e) {
        print("Error checking initial auth state: $e");
      }
    }
    return null;
  }

  /// Get user role as String (e.g., "admin", "driver")
  Future<String> getUserRole() async {
    final user = _firebaseService.getCurrentUser();
    if (user == null) throw Exception("No user logged in");

    final snapshot = await _firebaseService.getUserData(user.uid);
    if (!snapshot.exists) throw Exception("User data not found");

    final data = snapshot.value as Map<dynamic, dynamic>;
    if (!data.containsKey('role')) throw Exception("User role not found");

    return data['role'] as String;
  }
}
