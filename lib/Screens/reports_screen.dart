import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _formKey = GlobalKey<FormState>(); // form key for validation

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isLoading = false; // loading state

  File? _image;
  final ImagePicker _picker = ImagePicker();

  // pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // show image source bottom sheet
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Select Evidence Source',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: Color(0xFF4FB062),
              ),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF4FB062),
              ),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // get user live location
  Future<Position> _getUserLocation() async {
    bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception("Please enable location services");
    }

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied");
    }

    if (permission == LocationPermission.deniedForever) {
      await openAppSettings(); // opens phone settings
      throw Exception(
        "Location permanently denied. Please enable it in settings.",
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // upload evidence image to firebase storage
  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    final fileName =
    DateTime.now().millisecondsSinceEpoch.toString();

    final ref = FirebaseStorage.instance
        .ref()
        .child("drug_reports/$fileName.jpg");

    await ref.putFile(_image!);

    return await ref.getDownloadURL();
  }

  // submit report to firestore
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // get current user gps
      Position position = await _getUserLocation();

      // upload image if available
      String? imageUrl = await _uploadImage();

      // save report to firestore
      await FirebaseFirestore.instance
          .collection("drug_reports")
          .add({
        "drugName": _nameController.text.trim(),
        "masCode": _codeController.text.trim(),
        "description": _descController.text.trim(),
        "location": _locationController.text.trim(),
        "latitude": position.latitude,
        "longitude": position.longitude,
        "imageUrl": imageUrl,
        "status": "pending",
        "timestamp":
        FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _showSuccessDialog();

      // clear form
      _nameController.clear();
      _codeController.clear();
      _descController.clear();
      _locationController.clear();

      setState(() {
        _image = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error submitting report: $e",
          ),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF4FB062),
                size: 80,
              ),
              const SizedBox(height: 16),
              const Text(
                "Report Submitted",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Thank you for helping keep our community safe. Our team will verify this report immediately.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF2A6074),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType keyboardType =
        TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: icon != null
                ? Icon(
              icon,
              color:
              const Color(0xFF4FB062),
              size: 22,
            )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(12),
              borderSide:
              const BorderSide(
                color: Color(0xFF4FB062),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Report Fake Drug",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInputField(
                controller: _nameController,
                label: "Drug Name",
                hint: "Enter drug name",
                icon:
                Icons.medication_outlined,
                validator: (value) =>
                value == null ||
                    value.isEmpty
                    ? "Enter drug name"
                    : null,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _codeController,
                label: "MAS Code",
                hint: "Scratch code",
                icon:
                Icons.qr_code_scanner,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller:
                _locationController,
                label:
                "Pharmacy / Address",
                hint:
                "Where did you buy this?",
                icon:
                Icons.location_on_outlined,
                validator: (value) =>
                value == null ||
                    value.isEmpty
                    ? "Enter location"
                    : null,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller:
                _descController,
                label: "Description",
                hint:
                "Why do you suspect it is fake?",
                maxLines: 4,
                validator: (value) =>
                value == null ||
                    value.isEmpty
                    ? "Provide description"
                    : null,
              ),
              const SizedBox(height: 20),

              InkWell(
                onTap: () =>
                    _showImageSourceActionSheet(
                      context,
                    ),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration:
                  BoxDecoration(
                    border: Border.all(
                      color: Colors.grey
                          .shade300,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                        12),
                  ),
                  child: _image == null
                      ? const Center(
                    child: Text(
                      "Upload Evidence Image",
                    ),
                  )
                      : ClipRRect(
                    borderRadius:
                    BorderRadius
                        .circular(
                        12),
                    child: Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _submitReport,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    color:
                    Colors.white,
                  )
                      : const Text(
                    "Submit Report",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}