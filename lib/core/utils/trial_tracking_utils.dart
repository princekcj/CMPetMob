import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimeTrackingUtils {
  Future<void> updateTrialTimeFlag(User? user) async {
    try {
      if (user != null) {
        // Reference to the user document in Firestore
        DocumentReference<Map<String, dynamic>> userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Get the current document snapshot
        DocumentSnapshot<Map<String, dynamic>> snapshot = await userDoc.get();

        // Calculate elapsed days since account creation
        final creationTime = user.metadata.creationTime;
        final currentTime = DateTime.now();
        final elapsedDays = currentTime.difference(creationTime!).inDays;

        // Update the 'trial_time_completed' field
        if (elapsedDays >= 37) {
          await userDoc.update({'trial_time_completed': true});
          print('User has completed the trial period.');
        } else {
          await userDoc.set({'trial_time_completed': false}, SetOptions(merge: true));
          print('User is still within the trial period.');
        }
      }
    } catch (e) {
      print('Error updating trial time flag: $e');
    }
  }

  bool isTrialTimeCompleted(User? user) {
    try {
      if (user != null) {
        // Reference to the user document in Firestore
        DocumentReference<Map<String, dynamic>> userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Get the current document snapshot
        DocumentSnapshot<Map<String, dynamic>> snapshot = userDoc.get() as DocumentSnapshot<Map<String, dynamic>>;

        // Check the 'trial_time_completed' field
        if (snapshot.exists) {
          return snapshot.get('trial_time_completed') ?? false;
        } else {
          print('User document does not exist.');
          return false;
        }
      } else {
        print('User is null.');
        return false;
      }
    } catch (e) {
      print('Error checking trial time flag: $e');
      return false;
    }
  }

  Future<void> createTrialTimeFlag(User? user) async {
    try {
      if (user != null) {
        // Reference to the user document in Firestore
        DocumentReference<Map<String, dynamic>> userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Set the initial 'trial_time_completed' field to false
        await userDoc.set({'trial_time_completed': false});

        print('Trial time flag created for user.');
      }
    } catch (e) {
      print('Error creating trial time flag: $e');
    }
  }

  bool updateTrialTimeFlagIfNeeded(User? user) {
    try {
      if (user != null) {
        bool trialTimeCompleted = isTrialTimeCompleted(user);
        if (!trialTimeCompleted) {
          updateTrialTimeFlag(user);
        }
        return trialTimeCompleted;
      } else {
        return false; // User is null
      }
    } catch (e) {
      print('Error updating trial time flag: $e');
      return false; // Return false in case of error
    }
  }

}
