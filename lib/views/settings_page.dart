import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.settings, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Settings Page',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
              ),
              SizedBox(height: 10),
              Text(
                'User profile and application settings will be managed here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700], fontFamily: 'Inter'),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Simulate saving settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Settings saved!', style: TextStyle(fontFamily: 'Inter'))),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Save Settings', style: TextStyle(fontSize: 16, fontFamily: 'Inter')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}