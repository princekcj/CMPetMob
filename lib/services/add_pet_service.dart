import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cmpets/core/app_export.dart';
import 'package:cmpets/services/pet_journal/appointments.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../auth/Auth_provider.dart';

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addPet(
      String petName,
      String imageUrl,
      String petWeight,
      String petType,
      List<String> allergies,
      String feedingInstructions,
      List<String> medications,
      List<Appointment> appointments,
      DateTime? dateOfBirth,
      String moreInfo,
      ) async {
    // Add pet data to Firestore
    final FirebaseAuth _auth = FirebaseAuth.instance;

    print("just before $appointments");

    final List<Map<String, dynamic>> appointmentsJson =
    appointments.map((appointment) => appointment.toJson()).toList();
    print("just before $appointmentsJson");

    await _firestore.collection('users').doc(_auth.currentUser?.uid).collection('pets').add({
      'name': petName,
      'image': imageUrl,
      'weight': petWeight,
      'type': petType, // Adding the 'type' field
      'allergies': allergies, // Adding the 'allergies' field as a list
      'feedingInstructions': feedingInstructions, // Adding 'feedingInstructions' field as a string
      'medications': medications, // Adding the 'medications' field as a list
      'appointments' : appointmentsJson,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth) : null, // Adding 'dateOfBirth' as a timestamp or null
      'moreInfo': moreInfo, // Adding 'moreInfo' as a string
    });
  }

  Future<void> updatePetAppt(
      String petId,
      List<Appointment> appointments,
      ) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      final petRef = _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('pets')
          .doc(petId);

      print("appts is $appointments and ref of pet is $petRef");

      final List<Map<String, dynamic>> appointmentsJson =
      appointments.map((appointment) => appointment.toJson()).toList();

      await petRef.update({
        'appointments': FieldValue.arrayUnion(appointmentsJson),
      });
    } catch (e) {
      print('No Pet Created Yet: $e');
    };

    print('Event Saved');
  }


  Future<void> updatePet(
      String petId, // Provide the unique identifier for the pet (document ID)
      String petName,
      String imageUrl,
      String petWeight,
      List<String> allergies,
      String feedingInstructions,
      List<String> medications,
      List<Appointment> appointments,
      DateTime? dateOfBirth,
      String moreInfo,
      ) async {
    // Update pet data in Firestore
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      final petRef = _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('pets')
          .doc(petId);

      final List<Map<String, dynamic>> appointmentsJson =
      appointments.map((appointment) => appointment.toJson()).toList();

      await petRef.update({
        'name': petName,
        'image': imageUrl,
        'weight': petWeight,
        'allergies': allergies,
        'feedingInstructions': feedingInstructions,
        'medications': medications,
        'appointments': appointmentsJson,
        'dateOfBirth': dateOfBirth != null
            ? Timestamp.fromDate(dateOfBirth)
            : null,
        'moreInfo': moreInfo,
      });
    } catch (e) {

    }
  }

  Future<String> uploadImageToStorage(String imagePath) async {
    final filePath = "$imagePath";
    final file = File(filePath);
    // Create the file metadata
    final metadata = SettableMetadata(contentType: "image/jpeg");

    // Get a reference to the storage bucket
    final storageReference = _storage.ref().child('images/$filePath');

    try {
      final snapshot = storageReference.putFile(file, metadata);

      await for (var event in snapshot.snapshotEvents) {
        if (event.state == TaskState.running) {
          final progress = 100.0 * (event.bytesTransferred / event.totalBytes);
          print("Upload is $progress% complete.");
        } else if (event.state == TaskState.success) {
          // Handle successful uploads on completion
          final String downloadUrl = await event.ref.getDownloadURL();
          return downloadUrl;
        } else if (event.state == TaskState.error) {
          // Handle unsuccessful uploads
          // You may want to throw an exception here or handle the error as needed.
        }
      }
    } catch (e) {
      print("Exception: $e");
      // Handle FirebaseException or other exceptions here.
    }

    return ImageConstant.charles; // Return a default value or null if needed.
  }
}
