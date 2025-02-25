import 'package:flutter/material.dart';
import 'package:picaso_app1/screens/home_page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Optional: Hides debug banner
      home: HomePage(),
    );
  }
}