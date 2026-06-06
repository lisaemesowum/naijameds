import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:naijameds/Screens/cart_service.dart';
import 'package:naijameds/firebase_options.dart';
import 'package:naijameds/services/notification_service.dart';
import 'package:naijameds/splashScreens/splash_screen1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();
  await CartService.init(); // Initialize Cart persistence

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NaijaMeds',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2A6074),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Inter', // Assuming standard font or similar
      ),
      home: const SplashScreen1(),
    );
  }
}
