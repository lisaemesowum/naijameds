import 'package:flutter/material.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "About App",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top Card ===============================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xffDFF7E8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: Color(0xff17B169),
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Fake Drug Checker",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Check the authenticity of your medicines, even if they're counterfeit."
                        "Protecting lives by helping users verify medicines and identify fake drugs quickly and safely, we appreciate your kindness and support,THANK YOU FOR CHOOSING US.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Features Section ==================================================================================================================================
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "App Features",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
            ),

            const SizedBox(height: 15),

            buildFeatureCard(
              icon: Icons.qr_code_scanner_rounded,
              title: "Scan Drug Codes",
              subtitle:
              "Scan QR codes or barcodes to confirm medicine authenticity and verify it.",
            ),

            buildFeatureCard(
              icon: Icons.history,
              title: "Verification History",
              subtitle:
              "Keep track of all previously checked medicines easily and quickly.",
            ),

            buildFeatureCard(
              icon: Icons.warning_amber_rounded,
              title: "Fake Drug Alerts",
              subtitle:
              "Get notified when suspicious or fake medicines are detected and take necessary actions.",
            ),

            const SizedBox(height: 25),

            // Bottom Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff17B169),
                    Color(0xff0D8F57),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: const [
                  Icon(
                    Icons.health_and_safety_rounded,
                    color: Colors.white,
                    size: 45,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Stay Safe",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Our mission is to reduce the spread of counterfeit medicines and improve public health awareness and avoid misinformation in the medical field.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: const Color(0xffDFF7E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: const Color(0xff17B169),
              size: 28,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}