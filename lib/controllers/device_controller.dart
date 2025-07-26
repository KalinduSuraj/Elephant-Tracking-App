import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:network_tools/network_tools.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import '../models/device_model.dart';

class DeviceController extends ChangeNotifier {
  List<DeviceModel> _devices = [];
  int deviceCount =0;

  List<DeviceModel> get devices => _devices;

  Future<void> fetchConnectedDevices() async {
    _devices = [];
    notifyListeners();

    try {
      final info = NetworkInfo();
      final localIp = await info.getWifiIP();

      if (localIp == null || localIp.isEmpty) {
        throw Exception("Unable to get local IP address");
      }

      final subnet = localIp.substring(0, localIp.lastIndexOf('.'));

      await for (final host in HostScanner.discover(subnet, firstSubnet: 1, lastSubnet: 254)) {
        final url = 'http://${host.ip}/info';

        try {
          final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 2));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            print('Device Data: ${data}');

            final device = DeviceModel.fromJson(data, host.ip);
            _devices.add(device);
            deviceCount++;

            print('Device added: ${device.id} at ${device.ip}');
            print('Device Count: ${deviceCount}');

          }
        } catch (e) {
          print("Error : $e");
        }
      }

      notifyListeners();
    } catch (e) {
      print("Error discovering devices: $e");
    }
  }
}
