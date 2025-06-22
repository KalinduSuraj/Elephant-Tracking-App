import 'package:flutter/material.dart';
import 'package:elephant_tracking_app/controllers/auth_controller.dart'; // Updated import path
import 'package:elephant_tracking_app/controllers/elephant_controller.dart'; // Updated import path
import 'package:elephant_tracking_app/models/elephant.dart';
import 'package:elephant_tracking_app/views/map_view.dart'; // Updated import path
import 'package:elephant_tracking_app/views/settings_page.dart'; // Updated import path
import 'package:elephant_tracking_app/views/login_screen.dart'; // For logout navigation // Updated import path
import 'package:provider/provider.dart';
import 'package:elephant_tracking_app/models/user_app.dart'; // For UserRole // Updated import path
import 'package:elephant_tracking_app/views/admin_panel_screen.dart'; // Ensure correct path for admin panel // Updated import path

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Start listening to elephant data
    Provider.of<ElephantController>(context, listen: false).startListeningToElephants();
    // Start listening to location updates
    Provider.of<ElephantController>(context, listen: false).startLocationUpdates();
  }

  @override
  void dispose() {
    Provider.of<ElephantController>(context, listen: false).stopListeningToElephants();
    Provider.of<ElephantController>(context, listen: false).stopLocationUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final elephantController = Provider.of<ElephantController>(context);

    // The filtering logic for nearby elephants is now in ElephantController
    final int nearbyElephantsCount = elephantController.nearbyAlertElephants.length;
    final bool currentShouldShowAlert = elephantController.nearbyAlertElephants.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Elephant Tracker Dashboard', style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await authController.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              } else if (value == 'admin_panel' && authController.currentUser?.userRoleEnum == UserRole.admin) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminPanelScreen()), // Navigate to Admin Panel
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings', style: TextStyle(fontFamily: 'Inter')),
              ),
              if (authController.currentUser?.userRoleEnum == UserRole.admin)
                PopupMenuItem<String>(
                  value: 'admin_panel',
                  child: Text('Admin Panel', style: TextStyle(fontFamily: 'Inter')),
                ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout', style: TextStyle(fontFamily: 'Inter')),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'Current Location:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                        ),
                        SizedBox(height: 10),
                        Text(
                          elephantController.currentLocation == null
                              ? 'Fetching location...'
                              : 'Lat: ${elephantController.currentLocation!.latitude?.toStringAsFixed(4)}, Lng: ${elephantController.currentLocation!.longitude?.toStringAsFixed(4)}',
                          style: TextStyle(fontSize: 16, fontFamily: 'Inter'),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Nearby Elephants (within 800m & 10min):',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '$nearbyElephantsCount',
                          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blueAccent, fontFamily: 'Inter'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: MapView(), // Placeholder for the Map View
                  ),
                ),
              ],
            ),
          ),
          if (currentShouldShowAlert) // Use the state from controller
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