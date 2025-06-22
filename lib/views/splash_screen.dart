import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:elephant_tracking_app/views/login_screen.dart'; // Updated import path

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(Duration(seconds: 5), () {}); // 5-second delay
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Your logo here
            Image.asset(
              'assets/images/logo.png', // Ensure this path is correct in pubspec.yaml
              height: 200,
            ),
            SizedBox(height: 50),
            SpinKitFadingCircle(
              color: Colors.green, // Adjust color as needed
              size: 50.0,
            ),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}