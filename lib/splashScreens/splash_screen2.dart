
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:naijameds/splashScreens/splash_screen3.dart';

class SplashScreen2 extends StatefulWidget {
  const SplashScreen2({super.key});

  @override
  State<SplashScreen2> createState() => _SplashScreen2State();
}

class _SplashScreen2State extends State<SplashScreen2> {
  @override
  void initState(){
    super.initState();

    Timer(const Duration(seconds: 1),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const SplashScreen3()),
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
          "assets/splash/iPhone 13 & 14 - 2.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
