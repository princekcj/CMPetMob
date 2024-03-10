import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Function to calculate remaining days in the trial period
Future<int> calculateRemainingTrialDays(User? currentUser) async {
  // Get current user
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return 0; // Return 0 if user is null
  }

  // Get trial start date from user document
  DateTime? trialStartDate = user.metadata.creationTime;
  Timestamp trialStartDateTimestamp = Timestamp.fromDate(trialStartDate!);

  // Calculate trial duration in days
  int trialDuration = 37;

  // Calculate elapsed days since trial start date
  DateTime currentDate = DateTime.now();
  DateTime trialEndDate = trialStartDateTimestamp.toDate().add(Duration(days: trialDuration));
  int remainingDays = trialEndDate.difference(currentDate).inDays;

  return remainingDays;
}

// Function to check if the popup should be shown
// Function to check if the popup should be shown
bool shouldShowPopup() {
  // Get current date
  DateTime currentDate = DateTime.now();

  // Get last shown date from SharedPreferences
  SharedPreferences prefs; // Declare the variable without awaiting
  SharedPreferences.getInstance().then((value) {
    prefs = value;
    String? lastShownDate = prefs.getString('last_shown_date');

    // If last shown date is not today, return true (show popup)
    return lastShownDate != currentDate.toString();
  }).catchError((error) {
    // Handle any errors related to SharedPreferences
    print('Error fetching SharedPreferences: $error');
    return false; // Default to not showing the popup
  });

  // Default to not showing the popup (in case of any issues)
  return false;
}

// Function to show the trial popup
void showTrialPopup(BuildContext context, int remainingDays) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Trial Ending Soon'),
        content: Text('You have $remainingDays days left in your trial period.'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              // Save current date as last shown date in SharedPreferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              DateTime currentDate = DateTime.now();
              prefs.setString('last_shown_date', currentDate.toString().substring(0, 7));

              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
