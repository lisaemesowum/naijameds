import 'package:flutter/material.dart';
import 'package:naijameds/Screens/map_screen.dart';
import 'package:naijameds/Screens/reports_screen.dart';
import 'package:naijameds/Screens/scan_screen.dart';

import '../Screens/home_screen.dart';
import '../Screens/profile_screen.dart';
import '../Screens/search_screen.dart';

class DashboardScreeen extends StatefulWidget {
  const DashboardScreeen({super.key});

  @override
  State<DashboardScreeen> createState() => _DashboardScreeenState();
}

class _DashboardScreeenState extends State<DashboardScreeen> {
  List screen = [
    HomeScreen(),
    SearchScreen(),
    ReportsScreen(),
    ScanScreen(),
    MapScreen(),
    ProfileScreen(),
  ];
  int currentSection = 0;

  // void onTap(int index) {
  //   if (index == 1) {
  //   }else{
  //     setState(() {
  //       currentSection = index;
  //     });
  //   }
  // }
  void onTap(int index) {
    setState(() {
      currentSection = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screen[currentSection],

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            color: Color(0xFF4FB062),
        ),

        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
          ),

          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,

            currentIndex: currentSection,
            onTap: onTap,

            selectedItemColor: const Color(0xFF2A6074),
            unselectedItemColor: Colors.white,
            showUnselectedLabels: true,
            iconSize: 30,

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: "Search",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.report),
                label: "Reports",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner),
                label: "Scan",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: "Map",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
