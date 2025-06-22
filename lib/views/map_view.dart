import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Import flutter_map
import 'package:latlong2/latlong.dart'; // Import LatLng for flutter_map
import 'package:elephant_tracking_app/controllers/elephant_controller.dart'; // Your controller
import 'package:provider/provider.dart';

class MapView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final elephantController = Provider.of<ElephantController>(context);

    // Default location if GPS not ready
    final LatLng initialLatLng = elephantController.currentLocation != null
        ? LatLng(
      elephantController.currentLocation!.latitude!,
      elephantController.currentLocation!.longitude!,
    )
        : LatLng(7.8850, 80.7800); // Central Sri Lanka fallback

    List<Marker> markers = [];

    // User/train marker
    if (elephantController.currentLocation != null) {
      markers.add(
        Marker(
          point: LatLng(
            elephantController.currentLocation!.latitude!,
            elephantController.currentLocation!.longitude!,
          ),
          width: 80,
          height: 80,
          child: Icon(
            Icons.directions_railway,
            color: Colors.blue,
            size: 40.0,
          ),
          // anchor: Anchor.center,
        ),
      );
    }

    // Elephant warning markers
    for (var elephant in elephantController.nearbyAlertElephants) {
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
                    style: TextStyle(fontFamily: 'Inter'),
                  ),
                ),
              );
            },
            child: Icon(
              Icons.warning_amber,
              color: Colors.red,
              size: 40.0,
            ),
          ),
          // anchor: Anchor.center,
        ),
      );
    }

    return FlutterMap(
      options: MapOptions(
        center: initialLatLng,
        zoom: 12.0,
        maxZoom: 18.0,
        minZoom: 3.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.elephant_tracking_app',
        ),
        MarkerLayer(
          markers: markers,
        ),
      ],
    );
  }
}
