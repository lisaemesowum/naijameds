import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class DrugQrScreen extends StatefulWidget {
  final String docId; // This is the NAFDAC/MAS code

  const DrugQrScreen({super.key, required this.docId});

  @override
  State<DrugQrScreen> createState() => _DrugQrScreenState();
}

class _DrugQrScreenState extends State<DrugQrScreen> {
  String? qrData;
  bool isLoading = true;
  bool found = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await getDrugData(widget.docId);

      if (data != null) {
        // Prepare data for JSON encoding (handling non-encodable types like Timestamps)
        final cleanData = _toJsonCompatible(data);
        setState(() {
          qrData = jsonEncode(cleanData);
          found = true;
        });
      }
    } catch (e) {
      debugPrint("QR Data Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Helper to convert Firestore types to JSON-friendly types
  Map<String, dynamic> _toJsonCompatible(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) {
        return MapEntry(key, value.toDate().toIso8601String());
      }
      return MapEntry(key, value);
    });
  }

  Future<Map<String, dynamic>?> getDrugData(String code) async {
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('mac-code');

    // 1. Try searching by field 'code' as String
    var snapshot = await collection.where('code', isEqualTo: code).limit(1).get();
    if (snapshot.docs.isNotEmpty) return snapshot.docs.first.data();

    // 2. Try searching by field 'code' as Number
    final numCode = num.tryParse(code);
    if (numCode != null) {
      snapshot = await collection.where('code', isEqualTo: numCode).limit(1).get();
      if (snapshot.docs.isNotEmpty) return snapshot.docs.first.data();
    }

    // 3. Try searching by Document ID directly
    final doc = await collection.doc(code).get();
    if (doc.exists) return doc.data();

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Verified Drug QR", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: Color(0xFF4FB062))
            : !found
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 70, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        "Drug code ${widget.docId} not found",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Drug Authenticity QR",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2A6074),
                          ),
                        ),
                        const SizedBox(height: 30),
                        PrettyQrView.data(
                          data: qrData!,
                          errorCorrectLevel: QrErrorCorrectLevel.M,
                          decoration: const PrettyQrDecoration(
                            shape: PrettyQrSmoothSymbol(
                              color: Color(0xFF2A6074),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Code: ${widget.docId}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
