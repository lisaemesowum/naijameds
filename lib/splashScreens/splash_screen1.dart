import 'dart:async';

import 'package:flutter/material.dart';
import 'package:naijameds/splashScreens/splash_screen2.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  @override
  void initState(){
    super.initState();

    Timer(const Duration(seconds: 1),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const SplashScreen2()),
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
            "assets/splash/splash1.png",
        fit: BoxFit.cover,
        ),

      )
    );
  }
}
