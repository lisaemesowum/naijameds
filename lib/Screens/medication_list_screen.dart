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

    final userId =
        FirebaseAuth
            .instance
            .currentUser!
            .uid;

    return Scaffold(

      appBar: AppBar(
        title:
        const Text(
            "My Medications"),
      ),

      body: StreamBuilder(

        stream: FirebaseFirestore
            .instance
            .collection(
            "user_medications")
            .where(
          "userId",
          isEqualTo: userId,
        )
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return const Center(
              child: Text(
                "No medications yet",
              ),
            );
          }

          final meds =
              snapshot.data!.docs;

          return ListView.builder(

            itemCount: meds.length,

            itemBuilder:
                (context, index) {

              final med = meds[index];

              return Card(

                margin:
                const EdgeInsets.all(10),

                child: ListTile(

                  leading:
                  CircleAvatar(
                    child: Text(
                      med[
                      'medicationName']
                      [0],
                    ),
                  ),

                  title: Text(
                    med[
                    'medicationName'],
                  ),

                  subtitle: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [

                      Text(
                        med['dosage'],
                      ),

                      Text(
                        med['condition'],
                      ),
                    ],
                  ),

                  trailing:
                  PopupMenuButton(

                    onSelected:
                        (value) async {

                      if (value ==
                          "delete") {

                        await NotificationService
                            .cancelNotification(
                          med[
                          'notificationId'],
                        );

                        await FirestoreService()
                            .deleteMedication(
                          docId: med.id,
                        );
                      }
                    },

                    itemBuilder:
                        (context) => [

                      const PopupMenuItem(
                        value: "edit",
                        child:
                        Text("Edit"),
                      ),

                      const PopupMenuItem(
                        value: "delete",
                        child:
                        Text("Delete"),
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