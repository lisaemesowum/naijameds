// Handles all Firebase Firestore operations

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:naijameds/models/medication.dart';

class FirestoreService {

        // the firestore collection
        final CollectionReference medicationRef = FirebaseFirestore.instance.collection("medications");

        final _db = FirebaseFirestore.instance; // instance of firestore

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
}