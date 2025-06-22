import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:elephant_tracking_app/controllers/elephant_controller.dart';
import 'package:provider/provider.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final elephantController = Provider.of<ElephantController>(context, listen: false);
      if (elephantController.currentLocation != null) {
        _mapController.move(
          LatLng(
            elephantController.currentLocation!.latitude!,
            elephantController.currentLocation!.longitude!,
          ),
          15.0,
        );
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elephantController = Provider.of<ElephantController>(context);

    final LatLng initialLatLng = elephantController.currentLocation != null
        ? LatLng(
      elephantController.currentLocation!.latitude!,
      elephantController.currentLocation!.longitude!,
    )
        : LatLng(7.8850, 80.7800); // Central Sri Lanka

    List<Marker> markers = [];

    // Add train/user location marker
    if (elephantController.currentLocation != null) {
      markers.add(
        Marker(
          point: LatLng(
            elephantController.currentLocation!.latitude!,
            elephantController.currentLocation!.longitude!,
          ),
          width: 80,
          height: 80,
          child: Center(
            child: Icon(
              Icons.directions_railway,
              color: Colors.blue,
              size: 40.0,
            ),
          ),
        ),
      );
    }

    // Add elephant markers
    for (var elephant in elephantController.elephants) {
      markers.add(
        Marker(
          point: LatLng(elephant.lat, elephant.lng),
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Elephant ${elephant.id}\nLast seen: ${elephant.timestamp.toLocal().toString().split('.')[0]}',
                    style: const TextStyle(fontFamily: 'Inter'),
                  ),
                ),
              );
            },
            child: Transform.translate(
              offset: const Offset(0, -20), // Move up
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.red,
                    size: 30.0,
                  ),
                  Text(
                    elephant.id,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View', style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialLatLng,
              initialZoom: 12.0,
              maxZoom: 18.0,
              minZoom: 3.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.elephant_tracking_app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (elephantController.currentLocation != null) {
                    _mapController.move(
                      LatLng(
                        elephantController.currentLocation!.latitude!,
                        elephantController.currentLocation!.longitude!,
                      ),
                      15.0,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Centered on your location', style: TextStyle(fontFamily: 'Inter'))),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cannot get current location.', style: TextStyle(fontFamily: 'Inter'))),
                    );
                    elephantController.startLocationUpdates();
                  }
                },
                icon: const Icon(Icons.my_location),
                label: const Text('My Location', style: TextStyle(fontFamily: 'Inter')),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
