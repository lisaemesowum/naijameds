// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class Wrapper extends StatefulWidget {
//   const Wrapper({super.key});
//
//   @override
//   State<Wrapper> createState() => _WrapperState();
// }
//
// class _WrapperState extends State<Wrapper> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder(  //used to listen to a stream of data and rebuild its widget subtree whenever new data is emitted by the stream
//           stream: FirebaseAuth.instance.authStateChanges(),  //notifies your app in real-time whenever a user signs in or signs out.
//           builder: (context, snapshot){
//             if(snapshot.hasData){
//               return const
//             }else{
//
//             }
//           })
//     );
//   }
// }
