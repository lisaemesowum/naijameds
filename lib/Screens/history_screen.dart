import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final user = FirebaseAuth.instance.currentUser; // Initialize Firebase Authentication user object with current user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Scan History",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black,),
      ),

      body: StreamBuilder<QuerySnapshot>( // StreamBuilder to listen to changes in the history collection and rebuild the widget when the data changes or when the connection state changes
        stream: FirebaseFirestore.instance // FirebaseFirestore instance to get the history collection from the database
            .collection("history") // history collection
            .where("userId", isEqualTo: user?.uid) // where user id is equal to the current user id
            .orderBy("createdAt", descending: true) // order by created at in descending order
            .snapshots(), // get the snapshots of the history collection
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) { // if the connection state is waiting then return a circular progress indicator
            return const Center(child: CircularProgressIndicator(),); // circular progress indicator to show that the data is being fetched
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { // if the data is not available or the data is empty then return a message saying no scan history yet
            return const Center(
              child: Text(
                "No Scan History Yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,),
              ),
            );
          }

          final history = snapshot.data!.docs; // get the history data from the snapshot and store it in a variable

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: history.length,
            itemBuilder: (context, index) {

              final data = history[index]; // get the data from the history list and store it in a variable

              final bool isVerified = data["status"] == "Verified"; // check if the status is verified and store it in a variable

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    // Status Icon
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: isVerified
                            ? Colors.green.withOpacity(0.13)
                            : Colors.red.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(isVerified ? Icons.verified : Icons.warning_rounded,
                        color: isVerified
                            ? Colors.green
                            : Colors.red,
                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 15),

                    // Drug Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          Text(
                            data["drugName"],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text("Code: ${data["code"]}", style: const TextStyle(color: Colors.grey,),
                          ),
                        ],
                      ),
                    ),

                    // Status
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isVerified
                            ? Colors.green.withOpacity(0.12)
                            : Colors.red.withOpacity(0.12),
                        borderRadius:
                        BorderRadius.circular(30),
                      ),
                      child: Text(
                        data["status"],
                        style: TextStyle(
                          color: isVerified
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}