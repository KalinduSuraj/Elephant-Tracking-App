class Elephant {
  final String id;
  final double lat;
  final double lng;
  final DateTime timestamp;

  Elephant({
    required this.id,
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  // Factory constructor to create an Elephant from a Firebase JSON map
  factory Elephant.fromMap(Map<dynamic, dynamic> map, String id) {
    return Elephant(
      id: id,
      lat: map['position']['lat'] as double,
      lng: map['position']['lng'] as double,
      timestamp: DateTime.parse(map['timestamp']), // Assuming "YYYY/MM/DD HH:MM:SS"
    );
  }

  // Method to convert an Elephant to a Firebase JSON map (for potential future writing)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'position': {
        'lat': lat,
        'lng': lng,
      },
      'timestamp': timestamp.toIso8601String(), // ISO 8601 for consistent formatting
    };
  }
}