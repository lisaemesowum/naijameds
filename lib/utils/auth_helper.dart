import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../dashboard/dashboard_screeen.dart';
import '../Screens/auth_screen.dart';

void navigateProtected(
    BuildContext context, {
      int? index,
      Widget? screen,
    }) {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // If logged in, go to the requested destination
    if (index != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreeen(initialIndex: index)),
      );
    } else if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  } else {
    // If not logged in, go to Auth Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuthScreen(
          tabIndex: index,
          nextScreen: screen,
        ),
      ),
    );
  }
}
