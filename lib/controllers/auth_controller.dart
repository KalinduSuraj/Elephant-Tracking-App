import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elephant_tracking_app/services/firebase_service.dart'; // Updated import path
import 'package:elephant_tracking_app/models/user_app.dart'; // Updated import path

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
            // If user exists in Auth but not in DB (e.g., first login or manual creation)
            // This case might need special handling based on your app logic
            _currentUser = UserApp(uid: user.uid, email: user.email!, role: 'unknown');
          }
        } catch (e) {
          print("Error fetching user role: $e");
          _currentUser = UserApp(uid: user.uid, email: user.email!, role: 'unknown');
        }
      } else {
        _currentUser = null;
      }
      notifyListeners(); // Notify listeners (UI) about auth state change
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseService.signInWithEmailPassword(email, password);
      // The listener will update _currentUser and notify listeners
    } catch (e) {
      throw e; // Re-throw to be caught by the UI
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      // The listener will update _currentUser to null and notify listeners
    } catch (e) {
      print("Error signing out: $e");
      throw e;
    }
  }

  // Method to check initial auth state for routing
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
}