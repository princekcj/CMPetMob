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

        // Calculate elapsed days since account creation
        final creationTime = user.metadata.creationTime;
        final currentTime = DateTime.now();
        final elapsedDays = currentTime.difference(creationTime!).inDays;

        // Update the 'trial_time_completed' field
        if (elapsedDays >= 7) {
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

  Future<bool> isTrialTimeCompleted(User? user) async {
    try {
      if (user != null) {
        // Reference to the user document in Firestore
        DocumentReference<Map<String, dynamic>> userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Get the current document snapshot
        DocumentSnapshot<Map<String, dynamic>> snapshot = await userDoc.get();
        if (snapshot != null && snapshot.exists) {
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
        isTrialTimeCompleted(user).then((trialTimeCompleted) {
          if (!trialTimeCompleted) {
            updateTrialTimeFlag(user);
          }
        });
        // Note: This function now returns immediately and does not wait for isTrialTimeCompleted to complete.
        // If you need to return the value of trialTimeCompleted, you would need to make this function async and use await.
        return true; // Assume trial time is completed until proven otherwise
      } else {
        print('User is null.');
        return false;
      }
    } catch (e) {
      print('Error updating trial time flag: $e');
      return false; // Return false in case of error
    }
  }

  Future<bool> isFullVersionPurchased(User? user) async {
    try {
      if (user != null) {
        // Reference to the user document in Firestore
        DocumentReference<Map<String, dynamic>> userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Get the current document snapshot
        DocumentSnapshot<Map<String, dynamic>> snapshot = await userDoc.get();
        if (snapshot != null && snapshot.exists) {
          return snapshot.get('purchased_full_version') ?? false;
        } else {
          print('User document does not exist.');
          return false;
        }
      } else {
        print('User is null.');
        return false;
      }
    } catch (e) {
      print('Error checking purchased flag: $e');
      return false;
    }
  }

}
