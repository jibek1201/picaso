import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picaso_app1/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestBluetoothPermissions();
  runApp(MyApp());
}

Future<void> requestBluetoothPermissions() async {
  PermissionStatus scanStatus = await Permission.bluetoothScan.request();
  PermissionStatus connectStatus = await Permission.bluetoothConnect.request();

  if (scanStatus.isGranted && connectStatus.isGranted) {
    print("Bluetooth permissions granted");
  } else {
    print("Bluetooth permissions denied");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

