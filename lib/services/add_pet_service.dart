import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cmpets/core/app_export.dart';
import 'package:cmpets/services/pet_journal/appointments.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
      bool isNeutered, // New parameter: Is the pet neutered? (Yes/No)
      String vetName, // New parameter: Vet name (as a string)
      String insuranceProvider, // New parameter: Insurance provider (as a string)
      ) async {
    // Add pet data to Firestore
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // Print the appointments list before processing
    print("just before $appointments");

    // Convert the appointments list to JSON format
    final List<Map<String, dynamic>> appointmentsJson =
    appointments.map((appointment) => appointment.toJson()).toList();
    print("just before $appointmentsJson");

    // Add pet data to Firestore collection
    await _firestore.collection('users').doc(_auth.currentUser?.uid).collection('pets').add({
      'name': petName,
      'image': imageUrl,
      'weight': petWeight,
      'type': petType,
      'allergies': allergies,
      'feedingInstructions': feedingInstructions,
      'medications': medications,
      'appointments': appointmentsJson,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth) : null,
      'moreInfo': moreInfo,
      'isNeutered': isNeutered, // Store whether the pet is neutered (true/false)
      'vetName': vetName, // Store the vet's name
      'insuranceProvider': insuranceProvider, // Store the insurance provider
    });
  }


  Future<void> updatePetAppt(
      BuildContext context,
      String petId,
      List<Appointment> appointments,
      ) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      if (petId.length >= 1) {
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
        print('Event Saved');
      }
    } catch (e) {
      print('No Pet Created Yet: $e');
      print(petId.length);
    }
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
      bool isNeutered, // New parameter: Is the pet neutered? (Yes/No)
      String vetName, // New parameter: Vet name (as a string)
      String insuranceProvider, // New parameter: Insurance provider (as a string)
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
        'dateOfBirth': dateOfBirth != null
            ? Timestamp.fromDate(dateOfBirth)
            : null,
        'moreInfo': moreInfo,
        'isNeutered': isNeutered, // Store whether the pet is neutered (true/false)
        'vetName': vetName, // Store the vet's name
        'insuranceProvider': insuranceProvider, // Store the insurance provider
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

