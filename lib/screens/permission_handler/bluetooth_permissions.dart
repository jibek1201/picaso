import 'package:permission_handler/permission_handler.dart';

class BluetoothPermissionHandler {
  static Future<bool> requestBluetoothPermissions() async {
    PermissionStatus scanStatus = await Permission.bluetoothScan.request();
    PermissionStatus connectStatus = await Permission.bluetoothConnect.request();

    if (scanStatus.isGranted && connectStatus.isGranted) {
      print("Bluetooth permissions granted");
      return true;
    } else {
      print("Bluetooth permissions denied");
      return false;
    }
  }
}
