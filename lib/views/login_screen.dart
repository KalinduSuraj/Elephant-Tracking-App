import 'package:flutter/material.dart';
import 'package:elephant_tracking_app/controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:elephant_tracking_app/views/home_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'admin_panel_screen.dart'; // Import for SpinKit

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
        _isLoading = true;
      });
      final authController = Provider.of<AuthController>(context, listen: false);
      try {
        await authController.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        String role = await authController.getUserRole();
        // Navigate based on role
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
          );
        } else if (role == 'driver') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          // Unknown role, fallback
          setState(() {
            _errorMessage = 'Unknown user role: $role';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.lock,
                      size: 100,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.email),
                        filled: true, // Fill the background of the input field
                        fillColor: Colors.white, // Light background for text fields
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Theme.of(context).primaryColorDark, // Use darker theme color
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
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
                      onPressed: _isLoading ? null : _login, // Disable button while loading
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor, // Use theme color
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        minimumSize: const Size(double.infinity, 50), // Make button full width
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18, fontFamily: 'Inter'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // TextButton(
                    //   onPressed: () {
                    //     // Navigate to registration screen or forgotten password flow
                    //     // For now, let's just print a message
                    //     print('Don\'t have an account? Register Here clicked');
                    //   },
                    //   child: Text(
                    //     "Don't have an account? Register Here",
                    //     style: TextStyle(color: Theme.of(context).primaryColor, fontFamily: 'Inter'), // Use theme color
                    //   ),
                    // ),
                    // TextButton(
                    //   onPressed: () {
                    //     print('Forgot Password? clicked');
                    //   },
                    //   child: Text(
                    //     'Forgot Password?',
                    //     style: TextStyle(color: Theme.of(context).primaryColor, fontFamily: 'Inter'), // Use theme color
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitThreeBounce(
                      color: Theme.of(context).primaryColor,
                      size: 50.0,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Logging In...',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Preparing your dashboard.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

