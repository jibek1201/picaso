import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Bluetooth_Service {
  FlutterBluePlus flutterBlue = FlutterBluePlus();
  BluetoothDevice? connectedDevice;

  Future<void> scanAndConnect() async {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) async {
      try {
        // Find the device by name
        ScanResult? foundResult;
        for (ScanResult r in results) {
          if (r.device.name == "Picasso") {
            foundResult = r;
            break;
          }
        }

        if (foundResult != null) {
          await FlutterBluePlus.stopScan();
          connectedDevice = foundResult.device;
          await connectedDevice?.connect();
          print("Connected to ${connectedDevice!.name}");
        } else {
          print("Device not found");
        }
      } catch (e) {
        print("Error during scan and connection: $e");
      }
    });
  }

  Future<void> sendImage(String imagePath) async {
    if (connectedDevice == null) {
      print("No device connected");
      return;
    }


    File imageFile = File(imagePath);
    List<int> imageBytes = await imageFile.readAsBytes();

    List<BluetoothService> services = (await connectedDevice!.discoverServices()).cast<BluetoothService>();

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          await characteristic.write(imageBytes);
          print("Image sent!");
          return;
        }
      }
    }

    print("No writable characteristic found.");
  }
}
