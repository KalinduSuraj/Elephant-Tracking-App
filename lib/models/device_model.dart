class DeviceModel {
  final String id;
  final String ip;
  final double lat;
  final double lng;
  final String time;

  DeviceModel({
    required this.id,
    required this.ip,
    required this.lat,
    required this.lng,
    required this.time,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json, String ip) {
    return DeviceModel(
      id: json['id'],
      ip: ip,
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      time: json['time'] ?? '',
    );
  }
}
