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

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  final ImagePicker picker = ImagePicker();
  bool isScanned = false;
  bool isTorchOn = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Professional scanning laser animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  void onDetect(BarcodeCapture capture) {
    if (isScanned) return;

    final String? code = capture.barcodes.first.rawValue;
    debugPrint("SCANNED: $code");

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
        child: CircularProgressIndicator(color: Color(0xFF17B169)),
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

      // Navigate to results screen and wait for user to come back
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
          isScanned = false; // Allow scanning again after returning from result screen
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
        child: CircularProgressIndicator(color: Color(0xFF17B169)),
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
    double scanAreaSize = 280.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scanWindow = Rect.fromCenter(
            center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
            width: scanAreaSize,
            height: scanAreaSize,
          );

          return Stack(
            children: [
              // 1. Camera Feed (Bottom Layer)
              MobileScanner(
                controller: controller,
                onDetect: onDetect,
                fit: BoxFit.cover,
                scanWindow: scanWindow,
              ),

              // 2. Centered Overlay & Visual Frame
              Stack(
                children: [
                  // Cutout Overlay
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.7),
                      BlendMode.srcOut,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            backgroundBlendMode: BlendMode.dstOut,
                          ),
                        ),
                        Center(
                          child: Container(
                            height: scanAreaSize,
                            width: scanAreaSize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Visual Frame, Corners, and Laser (Centered exactly with the cutout)
                  Center(
                    child: SizedBox(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      child: Stack(
                        children: [
                          // Border
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24, width: 2),
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          // Animated Laser Line
                          AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return Positioned(
                                top: 20 + ((scanAreaSize - 40) * _animation.value),
                                left: 20,
                                right: 20,
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF17B169),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF17B169).withOpacity(0.6),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          // Professional Corner Brackets
                          Positioned(top: 0, left: 0, child: _buildCorner(isTop: true, isLeft: true)),
                          Positioned(top: 0, right: 0, child: _buildCorner(isTop: true, isLeft: false)),
                          Positioned(bottom: 0, left: 0, child: _buildCorner(isTop: false, isLeft: true)),
                          Positioned(bottom: 0, right: 0, child: _buildCorner(isTop: false, isLeft: false)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // 3. UI Layer (Top Bar, Instructions, and Bottom Actions)
              SafeArea(
                child: Column(
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (Navigator.canPop(context)){
                                Navigator.pop(context);
                              }
                            },
                            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                            style: IconButton.styleFrom(backgroundColor: Colors.black26),
                          ),
                          const Text(
                            "Verify Product",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              controller.toggleTorch();
                              setState(() => isTorchOn = !isTorchOn);
                            },
                            icon: Icon(
                              isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(backgroundColor: Colors.black26),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    const Text(
                      "Align NAFDAC / MAS code within the frame",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    // Positioned below the frame
                    const SizedBox(height: 50),

                    const Spacer(),

                    // Bottom Actions with Gradient Background
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBottomAction(
                            icon: Icons.photo_library_rounded,
                            label: "Gallery",
                            onTap: scanImageFromGallery,
                          ),
                          _buildBottomAction(
                            icon: Icons.keyboard_rounded,
                            label: "Enter Code",
                            onTap: showManualInputDialog,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Color(0xFF17B169), width: 6) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Color(0xFF17B169), width: 6) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Color(0xFF17B169), width: 6) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Color(0xFF17B169), width: 6) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(40) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(40) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(40) : Radius.zero,
          bottomRight: !isTop && !isLeft ? const Radius.circular(40) : Radius.zero,
        ),
      ),
    );
  }

  Widget _buildBottomAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void showManualInputDialog() {
    TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Enter Code", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A6074))),
        content: TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Enter MAS scratch code",
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              String code = codeController.text.trim();
              Navigator.pop(context);
              if (code.isNotEmpty) {
                verifyDrug(code);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF17B169),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Verify", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
