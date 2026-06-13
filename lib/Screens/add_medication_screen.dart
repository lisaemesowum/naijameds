import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naijameds/services/notification_service.dart';
import '../services/firestore_service.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {


  final _formKey = GlobalKey<FormState>(); // form key for validation

  final medicationController = TextEditingController();
  final dosageController = TextEditingController();
  final quantityController = TextEditingController();
  final notesController = TextEditingController();

  String frequency = "Once Daily";
  String condition = "Hypertension";

  DateTime startDate = DateTime.now();
  DateTime refillDate = DateTime.now().add(const Duration(days: 30)); // default 30 days

  TimeOfDay reminderTime = TimeOfDay.now(); // current time

  File? prescriptionImage; // prescription image file

  bool isLoading = false;

  final Color primaryColor = const Color(0xFF2A6074);
  final Color accentColor = const Color(0xFF17B169);

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        prescriptionImage = File(picked.path);
      });
    }
  }

  Future<void> saveMedication() async {
    // Check if all fields are valid and show message if not
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all required fields"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      int quantity = int.tryParse(quantityController.text) ?? 0;
      int frequencyCount = getRegularCount();

      // Calculate refill date
      int daysUntilRefill = frequencyCount > 0 ? (quantity / frequencyCount).floor() : 30;
      DateTime refillDate = startDate.add(Duration(days: daysUntilRefill));

      int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Construct the scheduled time for the reminder
      DateTime scheduledDateTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        reminderTime.hour,
        reminderTime.minute,
      );

      // If the scheduled time is in the past, move it to the next day
      if (scheduledDateTime.isBefore(DateTime.now())) {
        scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
      }

      await FirestoreService().addMedication(
        medicationName: medicationController.text.trim(),
        dosage: dosageController.text.trim(),
        frequency: frequency,
        quantity: quantity,
        condition: condition,
        startDate: startDate,
        refillDate: refillDate,
        reminderTime: reminderTime.format(context),
        notificationId: notificationId,
        notes: notesController.text.trim(),
        prescriptionImage: prescriptionImage,
      );

      await NotificationService.scheduleMedicationReminder(
        id: notificationId,
        title: "Medication Reminder",
        body:
        "It's time to take ${medicationController.text} (${dosageController.text}). Please take your medication now.",
        scheduledTime: scheduledDateTime,
      );

      if (!mounted) return;
      
      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Medication added successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  int getRegularCount() {
    switch (frequency) {
      case "Twice Daily":
        return 2;
      case "Three Times Daily":
        return 3;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.green.shade100,
      appBar: AppBar(
        backgroundColor:primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Add Medication",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.green, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("General Information"),
              const SizedBox(height: 16),
              _buildTextField(
                controller: medicationController,
                label: "Medication Name",
                hint: "e.g. Paracetamol",
                icon: Icons.medication_rounded,
                validator: (val) => val == null || val.isEmpty ? "Enter medication name" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: dosageController,
                      label: "Dosage",
                      hint: "e.g. 500mg",
                      icon: Icons.monitor_weight_rounded,
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: quantityController,
                      label: "Quantity",
                      hint: "e.g. 30",
                      icon: Icons.inventory_2_rounded,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Schedule & Category"),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: "Frequency",
                value: frequency,
                items: ["Once Daily", "Twice Daily", "Three Times Daily"],
                icon: Icons.replay_circle_filled_rounded,
                onChanged: (val) => setState(() => frequency = val!),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: "Condition",
                value: condition,
                items: ["Hypertension", "Diabetes", "Malaria"],
                icon: Icons.health_and_safety_rounded,
                onChanged: (val) => setState(() => condition = val!),
              ),
              const SizedBox(height: 16),
              _buildTimePicker(),
              const SizedBox(height: 24),
              _buildSectionTitle("Additional Details"),
              const SizedBox(height: 16),
              _buildTextField(
                controller: notesController,
                label: "Notes",
                hint: "Add special instructions...",
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _buildImageUploader(),
              const SizedBox(height: 40),
              _buildSaveButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: primaryColor.withOpacity(0.6),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: icon != null ? Icon(icon, color: accentColor, size: 20) : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: accentColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: accentColor, size: 20),
            filled: true,
            fillColor: Colors.green.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: accentColor, width: 1.5),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 15)));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Reminder Time", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(context: context, initialTime: reminderTime);
            if (picked != null) setState(() => reminderTime = picked);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_filled_rounded, color: accentColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  reminderTime.format(context),
                  style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 15),
                ),
                const Spacer(),
                Icon(Icons.edit_calendar_rounded, size: 18, color: accentColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Prescription Evidence", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
        const SizedBox(height: 8),
        InkWell(
          onTap: pickImage,
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
            ),
            child: prescriptionImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade400, size: 40),
                      const SizedBox(height: 8),
                      Text("Upload Image", style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(prescriptionImage!, fit: BoxFit.cover),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isLoading ? null : saveMedication,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Save Medication",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
