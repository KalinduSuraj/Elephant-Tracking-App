import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elephant_tracking_app/services/firebase_service.dart';
import 'package:elephant_tracking_app/models/user_app.dart';

class UserController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  List<UserApp> _users = [];
  List<UserApp> get users => _users;
  bool get isLoading => _isLoading;

  // This method combines Firebase Auth user creation with Realtime DB role assignment.
  Future<void> createUserWithEmailPassword(String email, String password, String? name, String role) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Create user in Firebase Authentication
      UserCredential userCredential = await _firebaseService.createUserWithEmailPassword(email, password);
      String uid = userCredential.user!.uid;

      // 2. Save user data (including role) to Firebase Realtime Database
      await _firebaseService.setUserData(uid, {
        'email': email,
        'role': role,
        if (name != null) 'name': name,
      });

      // After creation, refresh the list of users
      await fetchUsers();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('The email address is already in use by another account.');
      } else if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      }
      throw Exception('Firebase Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firebaseService.getAllUsersData();
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        List<UserApp> fetchedUsers = [];
        data.forEach((uid, userData) {
          try {
            fetchedUsers.add(UserApp.fromMap(userData as Map<dynamic, dynamic>, uid));
          } catch (e) {
            print("Error parsing user data for $uid: $e");
          }
        });
        _users = fetchedUsers;
      } else {
        _users = [];
      }
    } catch (e) {
      print("Error fetching all users: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Deleting user from Firebase Authentication (client-side can only delete current user)
      // For deleting arbitrary users, a Firebase Cloud Function or Admin SDK would be needed.
      // Here, we simulate deletion from Auth and delete from Realtime DB.
      // If `auth.currentUser.uid == uid`, then `await _auth.currentUser.delete();` could be used.
      // Otherwise, this part would be a backend call.

      await _firebaseService.deleteUserData(uid); // Delete from Realtime DB

      // After deletion, refresh the list of users
      await fetchUsers();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
