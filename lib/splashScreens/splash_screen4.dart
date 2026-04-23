import 'dart:async';

import 'package:flutter/material.dart';

import '../Screens/home_screen.dart';
import '../dashboard/dashboard_screeen.dart';

class SplashScreen4 extends StatefulWidget {
  const SplashScreen4({super.key});

  @override
  State<SplashScreen4> createState() => _SplashScreen4State();
}

class _SplashScreen4State extends State<SplashScreen4> {
  @override
  void initState(){
    super.initState();

    Timer(const Duration(seconds: 2),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const DashboardScreeen()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          "assets/splash/iPhone 13 & 14 - 4.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
