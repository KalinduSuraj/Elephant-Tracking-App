import 'package:flutter/material.dart';
import 'package:elephant_tracking_app/controllers/auth_controller.dart'; // Updated import path
import 'package:elephant_tracking_app/controllers/elephant_controller.dart'; // Updated import path
import 'package:elephant_tracking_app/models/elephant.dart';
import 'package:elephant_tracking_app/views/map_view.dart'; // Updated import path
import 'package:elephant_tracking_app/views/settings_page.dart'; // Updated import path
import 'package:elephant_tracking_app/views/login_screen.dart'; // For logout navigation // Updated import path
import 'package:provider/provider.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Flag to control the warning overlay visibility
  // It starts as false, and will be set by the controller or manually dismissed
  bool _isAlertVisible = false;

  @override
  void initState() {
    super.initState();
    // Start listening to elephant data
    Provider.of<ElephantController>(context, listen: false).startListeningToElephants();
    // Start listening to location updates
    Provider.of<ElephantController>(context, listen: false).startLocationUpdates();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to changes in elephantController's nearbyAlertElephants
    // This ensures the alert visibility is updated when the controller's state changes.
    Provider.of<ElephantController>(context).addListener(_updateAlertVisibility);
  }

  @override
  void dispose() {
    Provider.of<ElephantController>(context, listen: false).removeListener(_updateAlertVisibility);
    Provider.of<ElephantController>(context, listen: false).stopListeningToElephants();
    Provider.of<ElephantController>(context, listen: false).stopLocationUpdates();
    super.dispose();
  }

  void _updateAlertVisibility() {
    final elephantController = Provider.of<ElephantController>(context, listen: false);
    final bool controllerWantsAlert = elephantController.nearbyAlertElephants.isNotEmpty;

    // If the controller indicates an alert should be shown, ensure it becomes visible.
    // Otherwise, if the controller no longer demands an alert, hide it.
    if (controllerWantsAlert && !_isAlertVisible) {
      setState(() {
        _isAlertVisible = true;
      });
    } else if (!controllerWantsAlert && _isAlertVisible) {
      setState(() {
        _isAlertVisible = false;
      });
    }
  }


  // Custom Logout Confirmation Dialog
  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext context) {
        final authController = Provider.of<AuthController>(context, listen: false);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Rounded corners
          title: Text(
            'Logout Confirmation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to log out?',
                  style: TextStyle(
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
                  color: Theme.of(context).primaryColor, // Green color for cancel
                  fontFamily: 'Inter',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red for logout button
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Inter',
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss dialog
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

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final elephantController = Provider.of<ElephantController>(context);

    // The filtering logic for nearby elephants is now in ElephantController
    final int nearbyElephantsCount = elephantController.nearbyAlertElephants.length;
    final bool currentShouldShowAlert = elephantController.nearbyAlertElephants.isNotEmpty;

    // Get current user's email for greeting
    final String? userEmail = authController.currentUser?.email;
    final String greetingName = userEmail != null && userEmail.contains('@')
        ? userEmail.split('@')[0] // Get username part of email
        : 'Driver'; // Default to "Driver"

    return Scaffold(
      appBar: AppBar(
        title: Text('Elephant Tracker Dashboard', style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: Theme.of(context).primaryColor, // Use theme color
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutConfirmationDialog(context), // Call custom dialog
          ),
          // Removed PopupMenuButton (3 dots) here
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // "Hi, Driver!" Greeting
                Text(
                  'Hi, $greetingName!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: Theme.of(context).primaryColor, // Use theme color
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome to your dashboard.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 20),

                // Train Location and Nearby Elephants Cards (Side-by-side)
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Icon(Icons.directions_railway, size: 50, color: Colors.blue),
                              SizedBox(height: 10),
                              Text(
                                'Train\nLocation:',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                              ),
                              SizedBox(height: 5),
                              Text(
                                elephantController.currentLocation == null
                                    ? 'Fetching...'
                                    : 'Lat: ${elephantController.currentLocation!.latitude?.toStringAsFixed(4)}\nLng: ${elephantController.currentLocation!.longitude?.toStringAsFixed(4)}',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, fontFamily: 'Inter'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16), // Spacer between cards
                    Expanded(
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Icon(Icons.park, size: 50, color: Colors.orange), // Elephant/wildlife icon
                              SizedBox(height: 10),
                              Text(
                                'Nearby\nElephants:',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '$nearbyElephantsCount detected',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, fontFamily: 'Inter', color: Colors.blueAccent),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Map View Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapView()),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(Icons.map, size: 50, color: Theme.of(context).primaryColor), // Use theme color
                          SizedBox(height: 10),
                          Text(
                            'Map View',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Settings Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(Icons.settings, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            'Settings',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isAlertVisible) // Check _isAlertVisible
            Positioned.fill(
              child: Container(
                color: Colors.red.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.white,
                        size: 100,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'WARNING!',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        'ELEPHANT ON RAILWAY!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '($nearbyElephantsCount elephant(s) detected)',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isAlertVisible = false; // Dismiss the alert
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColorDark, // Use a darker green for dismiss
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Dismiss Alert',
                          style: TextStyle(fontSize: 18, fontFamily: 'Inter'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}