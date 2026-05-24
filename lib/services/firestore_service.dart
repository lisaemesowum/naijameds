// Handles all Firebase Firestore operations

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:naijameds/models/medication.dart';

class FirestoreService {

        // the firestore collection
        final CollectionReference medicationRef = FirebaseFirestore.instance.collection("medications");

        final FirebaseFirestore _firestore = FirebaseFirestore.instance; // instance of firestore
        final _db = FirebaseFirestore.instance; // instance of firestore
        final FirebaseStorage _storage = FirebaseStorage.instance;

        final FirebaseAuth _auth = FirebaseAuth.instance; // instance of firebase auth

        // search medications from firebase
        Future <List<Medication>> searchMedications(String query) async {
        //   get matching medication
        final result = await medicationRef
            .where('name',isGreaterThanOrEqualTo: query) //  where name is greater than or equal to query
            .get();//  get the data

        //   convert firebase docs to medication objects

          return result.docs.map((doc){  //
            final data = doc.data() as Map<String, dynamic>;
            return Medication.fromFirestore(data);
          }).toList();
          }
        // Future<List<Medication>> searchMedications(String query) async {
        //   final snapshot = await FirebaseFirestore.instance
        //       .collection('medications')
        //       .where('name', isGreaterThanOrEqualTo: query)
        //       .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        //       .get();
        //
        //   return snapshot.docs.map((doc) => Medication.fromFirestore(doc as Map<String, dynamic>)).toList();
        // }
//         save message
      Future<void> saveMessage(Map<String, dynamic> message) async {
           await _db.collection('messages').add({
             ...message,
             "createdAt": FieldValue.serverTimestamp(),
           })  ;
      }

//       for report fake drugs
  Future<void> submitReport({
    required String drugName,
    required String masCode,
    required String location,
    required String description,
    File? image, // image file for evidence
})async{
          String imageUrl = "";
  //         image for uploads
    if(image != null){ // if image is not null
      String fileName =
      DateTime.now().millisecondsSinceEpoch.toString(); //

      Reference ref = _storage // reference to firebase storage bucket
          .ref()
          .child("reports") // reports folder
          .child("$fileName.jpg"); // file name

      await ref.putFile(image); // upload image to firebase storage

      imageUrl = await ref.getDownloadURL(); // get download url
    }
  //   save firestore
    await _db.collection("reports").add({
      "drugName": drugName,
      "code": masCode,
      "location": location,
      "description": description,
      "imageUrl": imageUrl,
      "userEmail": _auth.currentUser?.email ?? "Not Known",
      "userId":
      _auth.currentUser?.uid,

      "status": "pending",

      "createdAt":
      FieldValue.serverTimestamp(),
    });
  }
//   ===========================
// ==========================TO VERIFY DRUGS=========================================== // Dynamic values : data points that change automatically at runtime, rather than remaining fixed
  static Future<Map<String, dynamic>?> verifyDrug(String macCode) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("mac-code")
        .where("code", isEqualTo: macCode)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }


//================================handles drug verification================================================================================================

// \\\\\\\\\\\\\\\\\\\\\for the save history=\\\\\\\\\\\\\\\\\
Future<void> saveHistory({  required String drugName, required String code, required String status,})async{
    await _db.collection("history").add({
      "drugName": drugName,
      "code": code,
      "status": status,
      "userId": _auth.currentUser?.uid,
      "createdAt": FieldValue.serverTimestamp(),
    });
 }
//  for the add medician =======
  Future<void> addMedication({
    required String medicationName,
    required String dosage,
    required String frequency,
    required int quantity,
    required String condition,
    required DateTime startDate,
    required DateTime refillDate,
    required String reminderTime,
    required int notificationId,
    String? notes, // optional parameter for notes
    File? prescriptionImage, // optional parameter for prescription image
  }) async {

    String imageUrl = ""; // image url for prescription image

    // Upload prescription image
    if (prescriptionImage != null) { // if prescription image is not null then upload it to firebase storage
      final fileName = DateTime.now().millisecondsSinceEpoch.toString(); // generate file name

      final ref = _storage // reference to firebase storage bucket and file name
          .ref()
          .child("prescriptions")
          .child("$fileName.jpg");

      await ref.putFile(prescriptionImage); // upload prescription image to firebase storage

      imageUrl = await ref.getDownloadURL();
    }

    await _db.collection("user_medications").add({ // add medication to firebase firestore
      "userId": _auth.currentUser?.uid,
      "medicationName": medicationName,
      "dosage": dosage,
      "frequency": frequency,
      "quantity": quantity,
      "condition": condition,
      "startDate": Timestamp.fromDate(startDate),
      "refillDate": Timestamp.fromDate(refillDate),
      "reminderTime": reminderTime,
      "notificationId": notificationId,
      "prescriptionImage": imageUrl,
      "notes": notes ?? "",
      "isActive": true,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
//
  Future<void> updateMedication({
    required String docId,
    required Map<String, dynamic> data,
  }) async {

    await _db
        .collection("user_medications")
        .doc(docId)
        .update(data);
  }

  Future<void> deleteMedication({
    required String docId,
  }) async {

    await _db
        .collection("user_medications")
        .doc(docId)
        .delete();
  }
}

