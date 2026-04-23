import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController controller = MobileScannerController();

  bool isScanned = false;
  bool isTorchOn = false;

  void onDetect(BarcodeCapture capture) {
    if (isScanned) return;

    final String? code = capture.barcodes.first.rawValue;

    if (code != null) {
      isScanned = true;

      //  Show scanned result
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Scanned Code"),
          content: Text(code),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                isScanned = false;
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [

          /// CAMERA
          MobileScanner(
            controller: controller,
            onDetect: onDetect,
          ),

          ///  YOUR UI
          SafeArea(
            child: Column(
              children: [

                /// TOP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      /// ❌ Close button
                      // GestureDetector(
                      //   onTap: () => Navigator.pop(context),
                      //   child: const Icon(Icons.close, color: Colors.white, size: 30),
                      // ),

                      const Text(
                        "Scan NAFDAC Code",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),

                      /// Flash toggle
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

                /// SCAN FRAME
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

                /// BOTTOM BUTTONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [

                      /// Gallery
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Add gallery picker
                          },
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

                      /// Enter Code
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Add manual input
                          },
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

  /// GREEN CORNERS
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
}