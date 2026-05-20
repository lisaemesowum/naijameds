import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class MedicationListScreen
    extends StatelessWidget {

  const MedicationListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Check if user is logged in
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "User not logged in, Please login to continue",
          ),
        ),
      );
    }

    final userId = user.uid;

    return Scaffold(

      appBar: AppBar(
        title:
        const Text(
            "My Medications"),
      ),

      body: StreamBuilder(

        stream: FirebaseFirestore // Stream of medications from Firestore
            .instance
            .collection(
            "user_medications")
            .where(
          "userId",
          isEqualTo: userId,
        )
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) { // Loading state while fetching data
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }
          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Text(
                " Oops Something went wrong: ${snapshot.error}",
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {

            return const Center(
              child: Text(
                "No medications found yet 😕",
              ),
            );
          }

          final meds = snapshot.data!.docs;

          return ListView.builder(

            itemCount: meds.length,

            itemBuilder: (context, index) {

              final med = meds[index];
              return Card(margin:
                const EdgeInsets.all(10),

                child: ListTile(

                  leading:
                  CircleAvatar(
                    child: Text(med[
                      'medicationName'][0],),),
                  title: Text(med['medicationName'],),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text("Dosage: ${med['dosage'] ?? 'N/A'}"),
                      Text("Condition: ${med['condition'] ?? 'N/A'}"),
                      Text("Frequency: ${med['frequency'] ?? 'N/A'}"),
                      Text("Reminder: ${med['reminderTime'] ?? 'N/A'}"),
                    ],
                  ),

                  trailing: // Popup menu for editing and deleting
                  PopupMenuButton(
                    onSelected: (value) async {

                      if (value == "delete") {
                        try {
                          await NotificationService.cancelNotification(med['notificationId'],);
                          await FirestoreService().deleteMedication(docId: med.id,);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Medication deleted",
                              ),
                            ),
                          );
                        }catch (e){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: $e"),
                            ),
                          );
                        }
                      }
                      if (value == "edit") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Edit feature coming soon",
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: "edit",
                        child: Text("Edit"),
                      ),
                      PopupMenuItem(
                        value: "delete",
                        child: Text("Delete"),
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
}