import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:naijameds/Screens/result_screen.dart';
import 'package:naijameds/services/firestore_service.dart';
import 'package:naijameds/services/ocr_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController controller = MobileScannerController();
  final ImagePicker picker = ImagePicker();
  bool isScanned = false;
  bool isTorchOn = false;

  void onDetect(BarcodeCapture capture) {
    if (isScanned) return;

    final String? code = capture.barcodes.first.rawValue;

    if (code != null) {
      setState(() {
        isScanned = true;
      });
      verifyDrug(code);
    }
  }

  Future<void> verifyDrug(String code) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final data = await FirestoreService.verifyDrug(code);

      // Save to scan history
      try {
        await FirestoreService().saveHistory(
          drugName: data != null ? (data['drugName'] ?? "Authentic Drug") : "Invalid Product",
          code: code,
          status: data != null ? "Verified" : "Invalid",
        );
      } catch (e) {
        debugPrint("History Save Error: $e");
      }

      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading dialog

      // Await the navigation so we don't resume scanning until the user returns
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            isAuthenticated: data != null,
            code: code,
            data: data,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog on error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isScanned = false; // Allow scanning again after returning
        });
      }
    }
  }

  Future<void> scanImageFromGallery() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      String code = await OcrService.scanText(File(image.path));
      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading dialog
      verifyDrug(code);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: onDetect,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.white, size: 30),
                      ),
                      const Text(
                        "Scan NAFDAC Code",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.toggleTorch();
                          setState(() {
                            isTorchOn = !isTorchOn;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            isTorchOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Put the code inside the frame 👇",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 300,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Positioned(top: 1, left: 1, child: corner()),
                        Positioned(top: 0, right: 0, child: corner(isRight: true)),
                        Positioned(bottom: 0, left: 0, child: corner(isBottom: true)),
                        Positioned(bottom: 0, right: 0, child: corner(isRight: true, isBottom: true)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: scanImageFromGallery,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo, color: Colors.white),
                                SizedBox(width: 8),
                                Text("Gallery", style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: GestureDetector(
                          onTap: showManualInputDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.qr_code_scanner, color: Colors.white),
                                SizedBox(width: 8),
                                Text("Enter Code", style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget corner({bool isRight = false, bool isBottom = false}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: isBottom ? BorderSide.none : const BorderSide(color: Color(0xFF4FB062), width: 4),
          left: isRight ? BorderSide.none : const BorderSide(color: Color(0xFF4FB062), width: 4),
          right: isRight ? const BorderSide(color: Color(0xFF4FB062), width: 4) : BorderSide.none,
          bottom: isBottom ? const BorderSide(color: Color(0xFF4FB062), width: 4) : BorderSide.none,
        ),
      ),
    );
  }

  void showManualInputDialog() {
    TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter NAFDAC Code"),
        content: TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Enter code",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              String code = codeController.text.trim();
              Navigator.pop(context);
              if (code.isNotEmpty) {
                verifyDrug(code);
              }
            },
            child: const Text("Verify"),
          )
        ],
      ),
    );
  }
}
