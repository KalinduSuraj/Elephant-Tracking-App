import 'package:flutter/material.dart';
import 'package:elephant_tracking_app/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true; // For password visibility toggle

  @override
  void initState() {
    super.initState();
    final authController = Provider.of<AuthController>(context, listen: false);
    _emailController.text = authController.currentUser?.email ?? '';
    _nameController.text = authController.currentUser?.name ?? '';
    // Password is not fetched/displayed directly for security
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Circular Profile Icon
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.green[100], // Light green background
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.green, // Green icon
                ),
              ),
              SizedBox(height: 30),
              // Email Address Field (Read-only)
              TextField(
                controller: _emailController,
                readOnly: true, // Making email read-only as per typical user settings
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                style: TextStyle(fontFamily: 'Inter'),
              ),
              SizedBox(height: 20),
              // Name Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                style: TextStyle(fontFamily: 'Inter'),
              ),
              SizedBox(height: 20),
              // Password Field (Placeholder for changing password)
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter new password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                style: TextStyle(fontFamily: 'Inter'),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Simulate saving settings or trigger actual update logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Settings saved!', style: TextStyle(fontFamily: 'Inter'))),
                  );
                  // In a real app, you would call authController.updateUser or similar
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  minimumSize: Size(double.infinity, 50), // Make button full width
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Save Changes', style: TextStyle(fontSize: 18, fontFamily: 'Inter')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}