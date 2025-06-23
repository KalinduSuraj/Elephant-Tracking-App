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
  List<Elephant> _nearbyAlertElephants = []; // Filtered elephants

  List<Elephant> get elephants => _elephants;
  Position? get currentLocation => _currentLocation;
  List<Elephant> get nearbyAlertElephants => _nearbyAlertElephants;

  // Calculate distance in meters using latlong2
  double getDistance(double lat1, double lon1, double lat2, double lon2) {
    final Distance distance = Distance();
    return distance(LatLng(lat1, lon1), LatLng(lat2, lon2)); // in meters
  }

  void _updateNearbyAlertElephants() {
    List<Elephant> filteredList = [];

    if (_currentLocation != null) {
      final userLocation = _currentLocation!;

      for (var elephant in _elephants) {
        final double distance = getDistance(
          userLocation.latitude!,
          userLocation.longitude!,
          elephant.lat,
          elephant.lng,
        );

        final bool isWithinDistance = distance <= 800; // 800 meters

        final Duration diff = DateTime.now().difference(elephant.timestamp);
        final bool isRecentDetection = diff.inMinutes >= 0 && diff.inMinutes <= 10;


        if (isWithinDistance && isRecentDetection) {
          filteredList.add(elephant);
        }
      }
    }

    // Debug prints
    print('Current Time (local): ${DateTime.now()}');
    print('Current Time (UTC): ${DateTime.now().toUtc()}');
    for (var elephant in _elephants) {
      print('Elephant ${elephant.id} seen at: ${elephant.timestamp} (UTC)');
      print('→ Local: ${elephant.timestamp.toLocal()}');
      print('→ Difference in minutes: ${DateTime.now().difference(elephant.timestamp.toLocal()).inMinutes}');
    }

    _nearbyAlertElephants = filteredList;
    notifyListeners();
  }

  void startListeningToElephants() {
    _elephantSubscription?.cancel();
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
        _updateNearbyAlertElephants();
      } else {
        _elephants = [];
        _updateNearbyAlertElephants();
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

      _locationSubscription?.cancel();
      _locationSubscription = _locationService.getPositionStream().listen((position) {
        _currentLocation = position;
        _updateNearbyAlertElephants();
      }, onError: (error) {
        print("Error getting location updates: $error");
      });
    } catch (e) {
      print("Failed to start location updates: $e");
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
