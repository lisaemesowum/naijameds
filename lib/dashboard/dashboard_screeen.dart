import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:naijameds/Screens/auth_screen.dart';
import 'package:naijameds/Screens/map_screen.dart';
import 'package:naijameds/Screens/scan_screen.dart';

import '../Screens/home_screen.dart';
import '../Screens/profile_screen.dart';
import '../Screens/search_screen.dart';

class DashboardScreeen extends StatefulWidget {
  final int initialIndex;
  const DashboardScreeen({super.key, this.initialIndex = 0});

  @override
  State<DashboardScreeen> createState() => _DashboardScreeenState();
}

class _DashboardScreeenState extends State<DashboardScreeen> {
  final List<Widget> _screen = <Widget>[
    const HomeScreen(),
    const SearchScreen(),
    const ScanScreen(),
    const MapScreen(),
    const ProfileScreen(),
  ];

  int currentSection = 0;

  @override
  void initState() {
    super.initState();
    currentSection = widget.initialIndex;
  }

  void onTap(int index) {
    final user = FirebaseAuth.instance.currentUser;

    // Protected tabs: Search (1), Drug Scan (2), Map (3), and Profile (4)
    // Users must sign up or log in to access these features.
    final protectedTabs = [1, 2, 3, 4];

    if (protectedTabs.contains(index) && user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AuthScreen(
            tabIndex: index,
          ),
        ),
      );
      return;
    }

    setState(() {
      currentSection = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentSection,
        children: _screen,
      ),
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
                icon: Icon(Icons.qr_code_scanner),
                label: "Drug Scan",
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
