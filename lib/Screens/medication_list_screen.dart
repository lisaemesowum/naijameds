import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class MedicationListScreen extends StatelessWidget {
  const MedicationListScreen({super.key});

  final Color primaryColor = const Color(0xFF2A6074);
  final Color accentColor = const Color(0xFF17B169);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text("Please login to view your medications",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "My Medications",
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("user_medications")
            .where("userId", isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication_outlined, size: 100, color: Colors.grey.shade300),
                  const SizedBox(height: 20),
                  Text(
                    "No medications added yet",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final meds = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: meds.length,
            itemBuilder: (context, index) {
              final med = meds[index];
              final data = med.data() as Map<String, dynamic>;
              bool isActive = data['isActive'] ?? true;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.medication_rounded, color: accentColor),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['medicationName'] ?? "Unknown",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                Text(
                                  "${data['dosage']} • ${data['frequency']}",
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isActive,
                            activeColor: accentColor,
                            onChanged: (value) async {
                              await FirebaseFirestore.instance
                                  .collection("user_medications")
                                  .doc(med.id)
                                  .update({"isActive": value});
                              
                              if (value == false) {
                                await NotificationService.cancelNotification(data['notificationId']);
                              } else {
                                // Re-scheduling logic would go here if needed, 
                                // but typically handled when turning back on or by app logic
                              }
                            },
                          ),
                          _buildPopupMenu(context, med, data),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoChip(Icons.access_time_rounded, data['reminderTime'] ?? "N/A"),
                          _buildInfoChip(Icons.health_and_safety_outlined, data['condition'] ?? "General"),
                          _buildInfoChip(Icons.inventory_2_outlined, "Qty: ${data['quantity']}"),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildPopupMenu(BuildContext context, QueryDocumentSnapshot med, Map<String, dynamic> data) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: (value) {
        if (value == "edit") _showEditDialog(context, med, data);
        if (value == "delete") _showDeleteDialog(context, med, data);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: "edit", child: Text("Edit Details")),
        const PopupMenuItem(value: "delete", child: Text("Remove Medication", style: TextStyle(color: Colors.red))),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, QueryDocumentSnapshot med, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Medication?"),
        content: const Text("This will stop all reminders and delete the record."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await NotificationService.cancelNotification(data['notificationId']);
              await FirestoreService().deleteMedication(docId: med.id);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, QueryDocumentSnapshot med, Map<String, dynamic> data) {
    final medicationController = TextEditingController(text: data['medicationName']);
    final dosageController = TextEditingController(text: data['dosage']);
    final conditionController = TextEditingController(text: data['condition']);
    final frequencyController = TextEditingController(text: data['frequency']);
    final reminderController = TextEditingController(text: data['reminderTime']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20, left: 20, right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Edit Medication", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildEditField("Name", medicationController),
              _buildEditField("Dosage", dosageController),
              _buildEditField("Condition", conditionController),
              _buildEditField("Frequency", frequencyController),
              _buildEditField("Reminder Time", reminderController),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("user_medications")
                        .doc(med.id)
                        .update({
                      "medicationName": medicationController.text.trim(),
                      "dosage": dosageController.text.trim(),
                      "condition": conditionController.text.trim(),
                      "frequency": frequencyController.text.trim(),
                      "reminderTime": reminderController.text.trim(),
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
