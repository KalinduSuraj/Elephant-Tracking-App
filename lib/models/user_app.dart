enum UserRole { admin, driver, unknown }

class UserApp {
  final String uid;
  final String email;
  final String role; // Stores the role as a string as per Firebase
  final String? name; // Optional name for the user

  UserApp({required this.uid, required this.email, required this.role, this.name});

  // Factory constructor to create a UserApp from a Firebase JSON map
  factory UserApp.fromMap(Map<dynamic, dynamic> map, String uid) {
    return UserApp(
      uid: uid,
      email: map['email'] as String,
      role: map['role'] as String,
      name: map['name'] as String?, // Name is optional
    );
  }

  // Method to convert a UserApp to a Firebase JSON map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      if (name != null) 'name': name,
    };
  }

  // Helper to convert role string to enum
  UserRole get userRoleEnum {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'driver':
        return UserRole.driver;
      default:
        return UserRole.unknown;
    }
  }
}