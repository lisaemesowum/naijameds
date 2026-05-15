import 'package:cloud_firestore/cloud_firestore.dart';

class UserMedication {
  final String id;
  final String userId; // id of the user who owns this medication
  final String medicationName; // name of the medication
  final String dosage; // dosage of the medication
  final String frequency; // frequency of the medication
  final int quantity; // quantity of the medication
  final String condition;
  final DateTime startDate;
  final DateTime refillDate;
  final String reminderTime;
  final String? prescriptionImage; // image of prescription
  final String? notes;
  final bool isActive;
  final Timestamp createdAt;

//   constructor
UserMedication({
  required this.id,
  required this.userId,
  required this.medicationName,
  required this.dosage,
  required this.frequency,
  required this.quantity,
  required this.condition,
  required this.startDate,
  required this.refillDate,
  required this.reminderTime,
  this.prescriptionImage,
  this.notes,
  required this.isActive,
  required this.createdAt
});
factory UserMedication.fromFirestore(Map<String,dynamic> data, String docId){ // factory constructor
  return UserMedication(
    id: docId,
    userId: data["userId"] ?? "",
    medicationName: data["medicationName"] ?? "",
      dosage: data['dosage'] ?? '',
      frequency: data['frequency'] ?? '',
      quantity: data['quantity'] ?? 0,
      condition: data['condition'] ?? '',
      startDate: (data["startDate"] as Timestamp).toDate(),
      refillDate: (data['refillDate'] as Timestamp).toDate(),
      reminderTime: data['reminderTime'] ?? '',
      prescriptionImage: data['prescriptionImage'],
      notes: data['notes'],
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] ?? Timestamp.now(),
  );
}
  Map<String, dynamic> toMap() { // convert to map for firebase firestore and return map
    return {
      'userId': userId,
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'quantity': quantity,
      'condition': condition,
      'startDate': Timestamp.fromDate(startDate),
      'refillDate': Timestamp.fromDate(refillDate),
      'reminderTime': reminderTime,
      'prescriptionImage': prescriptionImage,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}