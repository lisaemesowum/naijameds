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

  DateTime startDate = DateTime.now();DateTime refillDate = DateTime.now().add(const Duration(days: 30),); // add 30 days to current date

  TimeOfDay reminderTime = TimeOfDay.now(); // current time

  File? prescriptionImage; // prescription image file

  bool isLoading = false;

  Future<void> pickImage() async { // function to pick image from gallery
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery,);

    if (picked != null) {
      setState(() {
        prescriptionImage = File(picked.path);
      });
    }
  }

  Future<void> saveMedication() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      int quantity = int.parse(quantityController.text); // parse quantity to int
      int frequencyCount = getRegularCount();

      // Auto refill calculation
      // DateTime refillDate = startDate.add(Duration(days: quantity),);
      int daysUntilRefill = (quantity / frequencyCount).floor(); // calculate days until refill

      DateTime refillDate = startDate.add( // add days until refill to start date
        Duration(days: daysUntilRefill),
      );

      int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000; // generate notification id for reminder

      await FirestoreService().addMedication(
        medicationName: medicationController.text.trim(),
        dosage: dosageController.text.trim(),
        frequency: frequency,
        quantity: int.parse(quantityController.text),
        condition: condition,
        startDate: startDate,
        refillDate: refillDate,
        reminderTime:
        reminderTime.format(context),
        notificationId:
        notificationId,
        notes: notesController.text.trim(),
        prescriptionImage: prescriptionImage,
      );
      // Schedule reminder
      await NotificationService
          .scheduleMedicationReminder(

        id: notificationId,

        title:
        "Medication Reminder",

        body:
        "Time to take ${medicationController.text}",

        scheduledTime: DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          reminderTime.hour,
          reminderTime.minute,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Medication added successfully"),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    } finally {

      setState(() {
        isLoading = false;
      });
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
  Future<void> scheduleReminders(
      int baseId,
      String medicationName,
      ) async {
    int regularCount = getRegularCount();

    for (int i = 0; i < regularCount; i++) {
      final scheduledDateTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        (reminderTime.hour + (i * (24 ~/ regularCount))) % 24, // adjust hour based on regular count and index
        reminderTime.minute,
      );

      await NotificationService.scheduleMedicationReminder(
        id: baseId + i,
        title: "Medication Reminder",
        body: "Time to take $medicationName",
        scheduledTime: scheduledDateTime,
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Medication"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              TextFormField(
                controller: medicationController,
                decoration: const InputDecoration(
                  labelText: "Medication Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter medication name";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: "Dosage",
                  hintText: "500mg",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: frequency,
                decoration: const InputDecoration(
                  labelText: "Frequency",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Once Daily",
                    child: Text("Once Daily"),
                  ),
                  DropdownMenuItem(
                    value: "Twice Daily",
                    child: Text("Twice Daily"),
                  ),
                  DropdownMenuItem(
                    value: "Three Times Daily",
                    child: Text("Three Times Daily"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    frequency = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField(
                value: condition,
                items: const [
                  DropdownMenuItem(
                    value: "Hypertension",
                    child: Text("Hypertension"),
                  ),
                  DropdownMenuItem(
                    value: "Diabetes",
                    child: Text("Diabetes"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    condition = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Condition",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

            ListTile(

                contentPadding:
                EdgeInsets.zero,

                title: const Text(
                  "Reminder Time",
                ),

                subtitle: Text(
                  reminderTime.format(
                      context),
                ),

                trailing: const Icon(
                  Icons.access_time,
                ),

                onTap: () async {

                  final picked =
                  await showTimePicker(

                    context: context,

                    initialTime:
                    reminderTime,
                  );

                  if (picked != null) {

                    setState(() {
                      reminderTime =
                          picked;
                    });
                  }
                },
            ),
              const SizedBox(height: 17),

              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Notes",
                  // hint: "Add any additional notes",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.upload),
                label: const Text("Upload Prescription"),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,

                height: 55,

                child: ElevatedButton(
                  onPressed:
                  isLoading ? null : saveMedication,

                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                    "Save Medication",
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