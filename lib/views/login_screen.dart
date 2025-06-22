import 'package:flutter/material.dart';
import 'package:elephant_tracking_app/controllers/auth_controller.dart'; // Updated import path
import 'package:provider/provider.dart';
import 'package:elephant_tracking_app/views/home_screen.dart'; // Updated import path

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null; // Clear previous errors
      });
      final authController = Provider.of<AuthController>(context, listen: false);
      try {
        await authController.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        // If login successful, navigate to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString(); // Display error message
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login', style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.email),
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
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.lock),
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
                SizedBox(height: 30),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontFamily: 'Inter'),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18, fontFamily: 'Inter'),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Navigate to registration screen or forgotten password flow
                    // For now, let's just print a message
                    print('Forgot password / Register new user clicked');
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.green, fontFamily: 'Inter'),
                  ),
                ),
              ],
            ),
          ),
        ),
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