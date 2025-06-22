import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:elephant_tracking_app/views/splash_screen.dart'; // Updated import path
import 'package:provider/provider.dart';
import 'package:elephant_tracking_app/controllers/auth_controller.dart'; // Updated import path
import 'package:elephant_tracking_app/controllers/elephant_controller.dart'; // Updated import path
import 'package:elephant_tracking_app/controllers/user_controller.dart'; // Updated import path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Ensure you have your Firebase options here, e.g.,
    // options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ElephantController()),
        ChangeNotifierProvider(create: (_) => UserController()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elephant Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        appBarTheme: AppBarTheme(
          elevation: 0, // Flat app bar for modern look
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ), // Added missing comma here
        // cardTheme: CardTheme(
        //   elevation: 5,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(15),
        //   ),
        // ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey, fontFamily: 'Inter'),
          hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'Inter'),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
      home: SplashScreen(),
    );
  }
}