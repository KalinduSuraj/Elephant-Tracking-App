import 'package:flutter/material.dart';
import 'package:elephant_tracking_app/controllers/user_controller.dart';
import 'package:elephant_tracking_app/models/user_app.dart';
import 'package:provider/provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch users when the screen initializes
    Provider.of<UserController>(context, listen: false).fetchUsers();
  }

  // Custom confirmation dialog for deleting a user
  Future<void> _showDeleteConfirmationDialog(BuildContext context, UserApp userToDelete) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext context) {
        final userController = Provider.of<UserController>(context, listen: false);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Confirm Deletion',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to delete user ${userToDelete.email}?',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontFamily: 'Inter',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red for delete button
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Inter',
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss dialog
                try {
                  await userController.deleteUser(userToDelete.uid);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User deleted successfully!', style: TextStyle(fontFamily: 'Inter'))),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting user: $e', style: TextStyle(fontFamily: 'Inter'))),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User List', style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator( // Allows pull-to-refresh
        onRefresh: () => userController.fetchUsers(),
        child: userController.users.isEmpty && !userController.isLoading // Assuming isLoading property on controller
            ? Center(
          child: userController.isLoading
              ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_off, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text('No users found.', style: TextStyle(color: Colors.grey[700], fontFamily: 'Inter')),
              SizedBox(height: 10),
              Text('Pull down to refresh or add a new user from Admin Dashboard.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontFamily: 'Inter')),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: userController.users.length,
          itemBuilder: (context, index) {
            final user = userController.users[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(Icons.person, color: Theme.of(context).primaryColor),
                ),
                title: Text(user.email, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                subtitle: Text('Role: ${user.role} ${user.name != null ? ' | Name: ${user.name}' : ''}', style: const TextStyle(fontFamily: 'Inter')),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmationDialog(context, user),
                ),
                onTap: () {
                  // Optional: Navigate to user detail screen or edit user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tapped on ${user.email}', style: TextStyle(fontFamily: 'Inter'))),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}