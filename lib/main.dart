// main.dart
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
    // Extracted colors from your logo.png and the new image for theme
    const Color primaryLogoGreen = Color(0xFF4F7942); // A muted forest green from the image
    const Color darkLogoGreen = Color(0xFF3A5C33);   // A darker shade for accents
    const Color lightBackgroundGreen = Color(0xFFF0F4F0); // A very pale green for the background

    return MaterialApp(
      title: 'Elephant Tracker',
      debugShowCheckedModeBanner: false, // Removed debug banner
      theme: ThemeData(
        // Using a MaterialColor based on the primary logo green
        primarySwatch: MaterialColor(
          primaryLogoGreen.value,
          const <int, Color>{
            50: Color(0xFFE3EAE2),
            100: Color(0xFFB8C8B5),
            200: Color(0xFF8DA788),
            300: Color(0xFF62865B),
            400: Color(0xFF4A7144),
            500: primaryLogoGreen, // Main green
            600: Color(0xFF47703D),
            700: darkLogoGreen, // Darker green
            800: Color(0xFF324F2A),
            900: Color(0xFF1E3019),
          },
        ),
        primaryColor: primaryLogoGreen, // Explicitly set primary color
        primaryColorDark: darkLogoGreen, // Explicitly set darker primary color for accents
        scaffoldBackgroundColor: lightBackgroundGreen, // Set background color for Scaffold
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
          backgroundColor: primaryLogoGreen, // Use primary logo green
        ),
        // cardTheme: CardTheme(
        //   elevation: 5,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(15),
        //   ),
        // ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primaryLogoGreen, // Use primary logo green
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
            borderSide: BorderSide(color: darkLogoGreen, width: 2), // Use darker green for focused border
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