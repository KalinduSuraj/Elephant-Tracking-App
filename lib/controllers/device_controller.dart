import 'package:flutter/material.dart';
import 'package:network_tools/network_tools.dart'; // or your custom HostScanner class
import 'package:network_info_plus/network_info_plus.dart';
import '../models/device_model.dart';

class DeviceController extends ChangeNotifier {
  DeviceModel _deviceModel = DeviceModel(0);

  DeviceModel get deviceModel => _deviceModel;

  Future<void> fetchConnectedDevices() async {
    try {
      final info = NetworkInfo();
      final localIp = await info.getWifiIP();

      if (localIp == null || localIp.isEmpty) {
        throw Exception("Unable to get local IP address");
      }

      final subnet = localIp.substring(0, localIp.lastIndexOf('.'));

      List<ActiveHost> activeHosts = [];

      await for (final host in HostScanner.discover(
        subnet,
        firstSubnet: 1,
        lastSubnet: 254,
      )) {
        print('Found device: ${host.ip}');
        activeHosts.add(host);
      }

      _deviceModel = DeviceModel(activeHosts.length);
      notifyListeners();
    } catch (e) {
      print("Error discovering devices: $e");
      _deviceModel = DeviceModel(0);
      notifyListeners();
    }
  }
}
