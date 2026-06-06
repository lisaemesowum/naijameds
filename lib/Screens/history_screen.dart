import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Color primaryColor = const Color(0xFF2A6074);
  final Color accentColor = const Color(0xFF17B169);
  final Color warningColor = const Color(0xFFE74C3C);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Scan History",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: user == null
          ? _buildLoginPrompt()
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("history")
            .where("userId", isEqualTo: user.uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint("Firestore Error: ${snapshot.error}");
            if (snapshot.error.toString().contains('failed-precondition')) {
              return _buildFallbackStream(user.uid);
            }
            return _buildErrorState(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          return _buildHistoryContent(snapshot.data!.docs);
        },
      ),
    );
  }

  Widget _buildHistoryContent(List<QueryDocumentSnapshot> docs) {
    int total = docs.length;
    int safe = docs.where((doc) => doc['status'] == 'Verified').length;
    int warning = total - safe;

    return Column(
      children: [

        // =========================
        // FIXED: STATS ROW OVERFLOW
        // =========================
        // BEFORE: Row with Expanded caused overflow on small screens
        // AFTER: Wrapped in SingleChildScrollView to prevent pixel overflow

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // 🔥 FIX: allows horizontal scroll instead of overflow
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: _buildStatCard(
                    "Total",
                    total,
                    primaryColor,
                    Icons.analytics_outlined,
                  ),
                ),
                const SizedBox(width: 12),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: _buildStatCard(
                    "Safe",
                    safe,
                    accentColor,
                    Icons.verified_outlined,
                  ),
                ),
                const SizedBox(width: 12),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: _buildStatCard(
                    "Warning",
                    warning,
                    warningColor,
                    Icons.report_problem_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),

        // =========================
        // LIST (UNCHANGED)
        // =========================
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _buildHistoryCard(data);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> data) {
    final bool isVerified = data["status"] == "Verified";
    final timestamp = data["createdAt"] as Timestamp?;
    String dateStr = "Recent";

    if (timestamp != null) {
      final date = timestamp.toDate();
      final months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      dateStr = "${date.day} ${months[date.month - 1]} ${date.year}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: (isVerified ? accentColor : warningColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                isVerified
                    ? Icons.verified_user_rounded
                    : Icons.gpp_bad_rounded,
                color: isVerified ? accentColor : warningColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["drugName"] ?? "Unknown Drug",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data["code"] ?? "N/A",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isVerified ? accentColor : warningColor).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isVerified ? "AUTHENTIC" : "WARNING",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: isVerified ? accentColor : warningColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackStream(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("history")
          .where("userId", isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildHistoryContent(snapshot.data!.docs);
      },
    );
  }

  Widget _buildEmptyState() => const Center(child: Text("No history found"));

  Widget _buildErrorState(String error) =>
      Center(child: Text("Error: $error"));

  Widget _buildLoginPrompt() =>
      const Center(child: Text("Please login"));
}