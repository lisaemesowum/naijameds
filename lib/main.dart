import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:naijameds/firebase_options.dart';
import 'package:naijameds/splashScreens/splash_screen1.dart';
import 'package:naijameds/splashScreens/splash_screen3.dart';
import 'package:firebase_ai/firebase_ai.dart';


import 'dashboard/dashboard_screeen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NaijaMeds',
      debugShowCheckedModeBanner: false,
      home: DashboardScreeen()
    );
  }
}
