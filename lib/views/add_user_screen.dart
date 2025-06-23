import 'package:flutter/material.dart';
import 'package:elephant_tracking_app/controllers/user_controller.dart';
import 'package:provider/provider.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedRole = 'driver'; // Default role for new users
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _createUser() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _selectedRole == null) {
      setState(() {
        _errorMessage = 'Please fill all required fields.';
        _isLoading = false;
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters.';
        _isLoading = false;
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
        const SnackBar(content: Text('User created successfully!', style: TextStyle(fontFamily: 'Inter'))),
      );
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creating user: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New User', style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.person_add_alt_1, size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: 20),
              Text(
                'Create a New Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter user email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter password (min 6 characters)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.white,
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
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name (Optional)',
                  hintText: 'Enter user\'s name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.badge),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.assignment_ind),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const <String>['admin', 'driver']
                    .map((String value) {
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
              const SizedBox(height: 30),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontFamily: 'Inter'),
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _createUser, // Disable button while loading
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : const Text(
                  'Create User',
                  style: TextStyle(fontSize: 18, fontFamily: 'Inter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}