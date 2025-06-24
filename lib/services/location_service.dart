import 'package:geolocator/geolocator.dart';

class LocationService {
  // Check if location services are enabled
  Future<bool> checkLocationServiceStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      throw Exception('Location services are disabled. Please enable them in your device settings.');
    }
    return serviceEnabled;
  }

  // Request location permissions
  Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied. Please grant them to use this feature.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable them manually from app settings.');
    }
    return permission;
  }

  // Get the current position once
  Future<Position> getCurrentPosition() async {
    await checkLocationServiceStatus();
    await requestLocationPermission();
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // Get continuous location updates
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters change
      ),
    );
  }
}