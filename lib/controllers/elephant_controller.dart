import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:elephant_tracking_app/models/elephant.dart'; // Updated import path
import 'package:elephant_tracking_app/services/firebase_service.dart'; // Updated import path
import 'package:elephant_tracking_app/services/location_service.dart'; // Updated import path
import 'dart:async';

class ElephantController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final LocationService _locationService = LocationService();
  StreamSubscription? _elephantSubscription;
  StreamSubscription? _locationSubscription;

  List<Elephant> _elephants = [];
  Position? _currentLocation;
  List<Elephant> _nearbyAlertElephants = []; // New list for filtered elephants

  List<Elephant> get elephants => _elephants;
  Position? get currentLocation => _currentLocation;
  List<Elephant> get nearbyAlertElephants => _nearbyAlertElephants; // Getter for filtered list

  // Haversine distance calculation (simplified, latlong2 package does this)
  double getDistance(double lat1, double lon1, double lat2, double lon2) {
    final Distance distance = Distance();
    return distance(LatLng(lat1, lon1), LatLng(lat2, lon2)); // Returns in meters by default
  }

  // New method to calculate and update the list of nearby alert elephants
  void _updateNearbyAlertElephants() {
    List<Elephant> filteredList = [];
    if (_currentLocation != null) {
      final userLocation = _currentLocation!;
      for (var elephant in _elephants) {
        final double distance = getDistance(
          userLocation.latitude!, userLocation.longitude!,
          elephant.lat, elephant.lng,
        );

        final bool isWithinDistance = distance <= 800; // Within 800 meters
        final bool isRecentDetection = DateTime.now().difference(elephant.timestamp).inMinutes <= 5; // Within 10 minutes

        if (isWithinDistance && isRecentDetection) {
          filteredList.add(elephant);
        }
      }
    }
    _nearbyAlertElephants = filteredList;
    notifyListeners(); // Notify UI that nearbyAlertElephants has changed
  }


  void startListeningToElephants() {
    _elephantSubscription?.cancel(); // Cancel previous subscription if any
    _elephantSubscription = _firebaseService.getElephantLocationsStream().listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        List<Elephant> fetchedElephants = [];
        data.forEach((key, value) {
          try {
            fetchedElephants.add(Elephant.fromMap(value as Map<dynamic, dynamic>, key));
          } catch (e) {
            print("Error parsing elephant data for $key: $e");
          }
        });
        _elephants = fetchedElephants;
        _updateNearbyAlertElephants(); // Recalculate filtered list when all elephants change
      } else {
        _elephants = []; // No elephants found or data removed
        _updateNearbyAlertElephants(); // Clear filtered list as well
      }
    }, onError: (error) {
      print("Error listening to elephant locations: $error");
    });
  }

  void stopListeningToElephants() {
    _elephantSubscription?.cancel();
    _elephantSubscription = null;
  }

  void startLocationUpdates() async {
    try {
      await _locationService.checkLocationServiceStatus();
      await _locationService.requestLocationPermission();

      _locationSubscription?.cancel(); // Cancel previous subscription if any
      _locationSubscription = _locationService.getPositionStream().listen((position) {
        _currentLocation = position;
        _updateNearbyAlertElephants(); // Recalculate filtered list when location changes
      }, onError: (error) {
        print("Error getting location updates: $error");
        // Handle specific errors, e.g., show a message to the user
      });
    } catch (e) {
      print("Failed to start location updates: $e");
      // Potentially show an alert dialog to the user
    }
  }

  void stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  @override
  void dispose() {
    stopListeningToElephants();
    stopLocationUpdates();
    super.dispose();
  }
}
