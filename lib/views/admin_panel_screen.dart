import 'package:flutter/material.dart';
import 'package:elephant_tracking_app/controllers/user_controller.dart'; // Updated import path
import 'package:elephant_tracking_app/models/user_app.dart'; // Updated import path
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel', style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: Colors.green,
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
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      // Implement delete user functionality
                                      // This is a complex operation as it involves deleting Firebase Auth user AND Realtime DB entry
                                      // For now, it will just show a confirmation.
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