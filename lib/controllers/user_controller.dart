import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elephant_tracking_app/services/firebase_service.dart'; // Updated import path
import 'package:elephant_tracking_app/models/user_app.dart'; // Updated import path

class UserController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<UserApp> _users = [];
  List<UserApp> get users => _users;

  // This method combines Firebase Auth user creation with Realtime DB role assignment.
  Future<void> createUserWithEmailPassword(String email, String password, String? name, String role) async {
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
    }
  }

  Future<void> fetchUsers() async {
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
      notifyListeners(); // Notify UI about updated user list
    } catch (e) {
      print("Error fetching all users: $e");
      // Handle error, e.g., show a message to the admin
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      // IMPORTANT: Deleting a user from Firebase Authentication requires
      // specific server-side or admin SDK implementation if you want to
      // delete *any* user. A client-side user can only delete themselves.
      // For an admin panel, you'd typically use a Cloud Function or Admin SDK.
      // For this client-side example, we'll only delete from Realtime DB.
      // A full implementation would involve deleting the Auth user as well.

      // For demonstration, we'll simulate deletion from Auth (not actually possible client-side for arbitrary users)
      // and delete from Realtime DB.
      await _firebaseService.deleteUserData(uid);

      // Refresh the list after deletion
      await fetchUsers();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}