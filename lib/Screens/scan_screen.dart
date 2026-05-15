import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
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
  final MobileScannerController controller = MobileScannerController(); // Initialize the MobileScannerController
  final ImagePicker picker = ImagePicker(); // Initialize the ImagePicker
  bool isScanned = false; // Initialize the scan state
  bool isTorchOn = false;


  //  this is live camera scan =======================================================================================================
  void onDetect(BarcodeCapture capture) {
    if (isScanned) return; // Prevent multiple scans from happening at once

    final String? code = capture.barcodes.first.rawValue; // Get the first barcode in the capture and get its value

    if (code != null) { // if the code is not null then do this
      isScanned = true; // Set the scan state to true

      //  Show scanned result
      verifyDrug(code);
    }
  }
  // ===================verifyDrug=======================================================================================================
  Future<void> verifyDrug(String code) async {
   showDialog( // Show loading dialog
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (_) => // Build the dialog
      const Center(
        child: CircularProgressIndicator(), //
      ),
    );
   final data = await FirestoreService.verifyDrug(code); // Verify the drug using the FirebaseService
   Navigator.push( // Push the result screen to the navigation stack and pass the data and code as arguments to the screen
     context,
     MaterialPageRoute(
       builder: (_) => ResultScreen(
         isAuthenticated: data != null, // Check if the data is not null
         code: code,
         data: data,
       ),
     ),
   );
   isScanned = false; // Reset the scan state
  }
  // ==================DONE FOR THE VERIFY DRUG ========================================================================================

  // -------------------------------OCR FOR IMAGE ------------------------------------------------------------------------------------------
  Future<void> scanImageFromGallery() async {

    final XFile? image = await picker.pickImage(source: ImageSource.gallery,); // Pick an image from the gallery and store it in variable

    if (image == null) return; // If image is null then return

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
      const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try { // Try to scan the image and store it in variable

      String code = await OcrService.scanText(File(image.path),); // Scan the image and store it in variable

      Navigator.pop(context); // Pop the loading dialog

      verifyDrug(code); // Verify the drug using the FirebaseService and pass the code as argument

    } catch (e) { // If there is an error then do this

      Navigator.pop(context); // Pop the loading dialog

      ScaffoldMessenger.of(context).showSnackBar( // Show a snack bar with the error message
        SnackBar( // Snack bar to show error message
          content: Text(e.toString()),
        ),
      );
    }
  }
  // --------------DONE ---------------------------------------------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          // -------------- CAMERA
          MobileScanner( // Mobile scanner to scan the camera
            controller: controller, // Pass the controller to the scanner
            onDetect: onDetect, // Pass the onDetect function to the scanner
          ),

          //  YOUR UI
          SafeArea(
            child: Column(
              children: [

                // TOP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      // Close button
                      GestureDetector(
                        onTap: () => Navigator.pop(context), // Pop the navigation stack
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

                      // Flash toggle
                      GestureDetector(
                        onTap: () {
                          controller.toggleTorch(); // Toggle the torch on/off using the controller
                          setState(() { // Update the state of the widget to reflect the change in the torch state
                            isTorchOn = !isTorchOn; // Toggle the torch state
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            isTorchOn ? Icons.flash_on : Icons.flash_off, // Show the appropriate icon based on the torch state
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

                // SCAN FRAME
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

                        //  GREEN CORNERS
                        Positioned(top: 1, left: 1, child: corner()), // GREEN CORNERS
                        Positioned(top: 0, right: 0, child: corner(isRight: true)), // GREEN CORNERS
                        Positioned(bottom: 0, left: 0, child: corner(isBottom: true)), // GREEN CORNERS
                        Positioned(bottom: 0, right: 0, child: corner(isRight: true, isBottom: true)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // BOTTOM BUTTONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [

                      // Scan from Camera Gallery
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            scanImageFromGallery(); // Scan the image from the gallery and store it in variable and pass it to the verifyDrug function as argument to the verifyDrug function
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
                            showManualInputDialog();
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

  // GREEN CORNERS
  Widget corner({bool isRight = false, bool isBottom = false}) { // Function to build the green corners of the scan frame
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: isBottom ? BorderSide.none : const BorderSide(color: Color(0xFF4FB062), width: 4), // Set the border of the corners based on the arguments passed to the function
          left: isRight ? BorderSide.none : const BorderSide(color: Color(0xFF4FB062), width: 4), //
          right: isRight ? const BorderSide(color: Color(0xFF4FB062), width: 4) : BorderSide.none,
          bottom: isBottom ? const BorderSide(color: Color(0xFF4FB062), width: 4) : BorderSide.none,
        ),
      ),
    );
  }

  void showManualInputDialog() {
    TextEditingController codeController = TextEditingController(); // Create a text editing controller to get the user input
    // Show the dialog
    showDialog(context: context,
        builder: (context) => AlertDialog(
          title: const Text("Enter NAFDAC Code"),
          content: TextField(
            controller: codeController,
             keyboardType: TextInputType.number, // Set the keyboard type to number
            decoration: const InputDecoration( // Set the decoration of the text field
              hintText: "Enter code", // Set the hint text
              border: OutlineInputBorder(), // Set the border
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton( // Create a button to verify the code using the verifyDrug function
              onPressed: () {
                String code = codeController.text.trim(); // Get the code from the text field and trim it
                Navigator.pop(context);

                if (code.isNotEmpty) { // If the code is not empty then do this

                  verifyDrug(code); // Verify the drug using the FirebaseService and pass the code as argument to the verifyDrug function
                }
              },
              child: const Text("Verify"), // Set the text of the button
            )
            ]
        ),
    );
  }
}