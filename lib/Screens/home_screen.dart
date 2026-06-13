import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:naijameds/Screens/chat_screen.dart';
import 'package:naijameds/Screens/history_screen.dart';
import 'package:naijameds/Screens/reports_screen.dart';
import 'package:naijameds/Screens/scan_screen.dart';
import 'package:naijameds/Screens/search_screen.dart';
import 'package:naijameds/Screens/report_details_screen.dart';
import 'package:naijameds/utils/auth_helper.dart';
import 'package:intl/intl.dart';

import 'DrugQrScreen.dart';
import 'add_medication_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryColor = const Color(0xFF2A6074);
  final Color accentColor = const Color(0xFF4FB062);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.green.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome to NaijaMeds",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Keep Nigeria Safe with NaijaMeds",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    // notifications
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: primaryColor,
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(20.0),
                // for search next page
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: accentColor,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Search for verified medications...",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Scan Hero Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 210),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FB062), Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FB062).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        bottom: -15,
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 190,
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Quick Drug Verify",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Scan MAS scratch code to check\nauthenticity instantly.",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // for the scan bottom button
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const ScanScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF2E7D32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 34,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                "Scan Now",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // Quick Services
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quick Services",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildServiceItem(
                          icon: Icons.report_problem_rounded,
                          label: "Reports",
                          color: Colors.orange,
                          onTap: () => navigateProtected(
                            context,
                            screen: const ReportsScreen(),
                          ),
                        ),
                        _buildServiceItem(
                          icon: Icons.forum_rounded,
                          label: "Consultant",
                          color: Colors.blue,
                          onTap: () => navigateProtected(
                            context,
                            screen: const ChatScreen(),
                          ),
                        ),
                        _buildServiceItem(
                          icon: Icons.history_rounded,
                          label: "History",
                          color: Colors.purple,
                          onTap: () => navigateProtected(
                            context,
                            screen: const HistoryScreen(),
                          ),
                        ),
                        _buildServiceItem(
                          icon: Icons.shopping_cart_rounded,
                          label: "Cart",
                          color: Colors.redAccent,
                          onTap: () => navigateProtected(context, screen: const CartScreen()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // Latest Drug Alerts Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Latest Drug Alerts",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Community Reports",
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // this is for the latest drug alerts cards
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("drug_reports")
                    .orderBy("timestamp", descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildNoReports();
                  }

                  final reports = snapshot.data!.docs;

                  return SizedBox(
                    height: 150,  // the size of the card
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report =
                        reports[index].data() as Map<String, dynamic>;

                        final timestamp =
                        report["timestamp"] as Timestamp?;

                        return SizedBox(
                          width: 320,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: _buildAlertCard(
                              drugName:
                              report["drugName"] ?? "Unknown Drug",
                              location:
                              report["location"] ?? "Unknown Location",
                              description:
                              report["description"] ?? "",
                              time: timestamp != null
                                  ? DateFormat('MMM dd, hh:mm a')
                                  .format(timestamp.toDate())
                                  : "Just now",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReportDetailsScreen(
                                      report: report,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoReports() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shield_outlined,
                color: Colors.grey.shade400,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "All Systems Clear",
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "No suspicious drug reports in your area.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ],
      ),
    );
  }

  // card for last drug alerts
  Widget _buildAlertCard({
    required String drugName,
    required String location,
    required String description,
    required String time,
    required VoidCallback onTap,
  }) {
    return Container(
      margin:  EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 6,
                  color:primaryColor ,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  drugName.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: primaryColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "HIGH ALERT",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 15, color: Colors.green.shade400),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                time,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Text(
                                "View Details",
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, size: 17, color: accentColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
