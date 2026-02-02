import 'package:ezpark/views/pages/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title:"EZPark",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingPage(),
      debugShowCheckedModeBanner: false,
      enableLog: true,
      defaultTransition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 300),
    );
  }
}
