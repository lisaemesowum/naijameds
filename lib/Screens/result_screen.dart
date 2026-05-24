import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final bool isAuthenticated;
  final String code;
  final Map<String, dynamic>? data;

  const ResultScreen({
    super.key,
    required this.isAuthenticated,
    required this.code,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Verification Result",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A6074)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2A6074)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            // Status Icon with themed background circle
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isAuthenticated ? Colors.green : Colors.red).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAuthenticated ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 90,
                color: isAuthenticated ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              isAuthenticated ? "Authentic Product" : "Counterfeit Warning",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isAuthenticated ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              "NAFDAC Code: $code",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 30),

            // Drug Details Information Card
            if (isAuthenticated && data != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow("Drug Name", data!['drugName'] ?? "N/A"),
                    const Divider(height: 24),
                    _buildInfoRow("Manufacturer", data!['manufacturer'] ?? "N/A"),
                    const Divider(height: 24),
                    _buildInfoRow("Description", data!['description'] ?? "N/A"),
                    const Divider(height: 24),
                    _buildInfoRow("Location", data!['location'] ?? "N/A"),
                    const Divider(height: 24),
                    _buildInfoRow("Status", data!['status'] ?? "Registered", isStatus: true),
                  ],
                ),
              ),
            ] else if (!isAuthenticated) ...[
              // Warning Card for unauthenticated drugs
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
                    SizedBox(height: 12),
                    Text(
                      "This code was not found in our secure database. Please do not consume this product and report it immediately using the Reports tab.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),

            // Done Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A6074),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build info rows inside the card
  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isStatus ? const Color(0xFF17B169) : const Color(0xFF2A6074),
            ),
          ),
        ),
      ],
    );
  }
}
