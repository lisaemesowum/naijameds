// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:naijameds/Screens/auth_screen.dart';
// import 'package:naijameds/dashboard/dashboard_screeen.dart';
//
//
// void navigateProtected(
// BuildContext context,
//     int index,
// )async {
//     final user = FirebaseAuth.instance.currentUser;
//
//     if(user != null){
//       Navigator.push(context,
//       MaterialPageRoute(
//           builder: (_)=> DashboardScreeen), // "Create a route/page and show whatever widget was passed into screen."
//       );
//     }else{
//       Navigator.push(context,
//       MaterialPageRoute(
//           builder: (_)=>  AuthScreen(
//             tabIndex: index,)),
//       );
//     }
//   }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../dashboard/dashboard_screeen.dart';
import '../Screens/auth_screen.dart';

void navigateProtected(
    BuildContext context,
    int index,
    ) {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreeen(
          initialIndex: index,
        ),
      ),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuthScreen(
          tabIndex: index,
        ),
      ),
    );
  }
}
