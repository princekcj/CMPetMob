import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

FirebaseAnalytics analytics = FirebaseAnalytics.instance;

// Log a custom event when a user performs a search
void logSearchEvent() {
  analytics.logEvent(
    name: 'search_event',
    parameters: <String, Object>{},  // Cast to Map<String, Object>
  );
}

// Log a custom event when a user performs a search
void logScanEvent(User? userId) {
  updateScanCount(userId);
  analytics.logEvent(
    name: 'scan_event',
    parameters: <String, Object>{
      'user_id': userId!.uid
    },
  );
}

// Log a custom event when a user uses a screen
void logScreenUsageEvent(String screenName) {
  analytics.logEvent(
    name: 'screen_usage_event',
    parameters: <String, Object>{
      'screen_name': screenName,
    },
  );
}
Future<void> updateScanCount(User? user) async {
  try {
    if (user != null) {
      // Reference to the user document in Firestore
      DocumentReference<Map<String, dynamic>> userDoc =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Get the current document snapshot
      DocumentSnapshot<Map<String, dynamic>> snapshot = await userDoc.get();

      // Check if the email field exists, and set it if it doesn't
        await userDoc.set({'email': user.email}, SetOptions(merge: true));

      // Update the 'scan_count' field by incrementing it by 1
      await userDoc.update({'scan_count': FieldValue.increment(1)});

      print('Scan count updated successfully! $userDoc');
    }
  } catch (e) {
    print('Error updating scan count: $e');
  }
}
