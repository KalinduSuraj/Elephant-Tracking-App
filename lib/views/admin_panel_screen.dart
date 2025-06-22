import 'package:flutter/material.dart';
import 'package:elephant_tracking_app/controllers/user_controller.dart'; // Updated import path
import 'package:elephant_tracking_app/models/user_app.dart'; // Updated import path
import 'package:provider/provider.dart';
import 'package:elephant_tracking_app/controllers/auth_controller.dart';

import 'login_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedRole = 'driver'; // Default role for new users
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Provider.of<UserController>(context, listen: false).fetchUsers();
  }

  void _createUser() async {
    setState(() {
      _errorMessage = null;
    });
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _selectedRole == null) {
      setState(() {
        _errorMessage = 'Please fill all required fields.';
      });
      return;
    }

    final userController = Provider.of<UserController>(context, listen: false);
    try {
      await userController.createUserWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
        _selectedRole!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User created successfully!', style: TextStyle(fontFamily: 'Inter'))),
      );
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creating user: $e';
      });
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Logout Confirmation', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
          content: Text('Are you sure you want to log out?', style: TextStyle(fontFamily: 'Inter')),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).primaryColor, fontFamily: 'Inter')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Logout', style: TextStyle(fontFamily: 'Inter')),
              onPressed: () async {
                Navigator.of(context).pop();
                await authController.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    _showLogoutConfirmationDialog();
  }

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel', style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create New User', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name (Optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: <String>['admin', 'driver'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontFamily: 'Inter')),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRole = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red, fontFamily: 'Inter'),
                        ),
                      ),
                    Center(
                      child: ElevatedButton(
                        onPressed: _createUser,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Create User', style: TextStyle(fontSize: 16, fontFamily: 'Inter')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Existing Users', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                      SizedBox(height: 10),
                      if (userController.users.isEmpty)
                        Center(child: Text('No users found.', style: TextStyle(fontFamily: 'Inter')))
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: userController.users.length,
                            itemBuilder: (context, index) {
                              final user = userController.users[index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: ListTile(
                                  title: Text(user.email, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                  subtitle: Text('Role: ${user.role} ${user.name != null ? ' | Name: ${user.name}' : ''}', style: TextStyle(fontFamily: 'Inter')),
                                  trailing: (user.email == 'driver@test.com' || user.email == 'admin@test.com')
                                      ? null // Hide delete button for these specific emails
                                      : IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      bool? confirmDelete = await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirm Deletion', style: TextStyle(fontFamily: 'Inter')),
                                            content: Text('Are you sure you want to delete user ${user.email}?', style: TextStyle(fontFamily: 'Inter')),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: Text('Cancel', style: TextStyle(fontFamily: 'Inter')),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(true),
                                                child: Text('Delete', style: TextStyle(color: Colors.red, fontFamily: 'Inter')),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirmDelete == true) {
                                        try {
                                          await userController.deleteUser(user.uid);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('User deleted successfully!', style: TextStyle(fontFamily: 'Inter'))),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error deleting user: $e', style: TextStyle(fontFamily: 'Inter'))),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
