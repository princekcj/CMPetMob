import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../core/utils/trial_tracking_utils.dart';


bool isAuthenticated() {
  final user = FirebaseAuth.instance.currentUser;
  return user != null;
}

final authProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final TimeTrackingUtils _timeTrackingUtils = TimeTrackingUtils();


  // User stream
  Stream<User?> get userStream => _auth.authStateChanges();

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Register a new user with email, password, and additional fields
  Future<void> register(
      String email,
      String password,
      String forename,
      String surname,
      String selectedOption,
      String selectedExpOption,
      ) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final  userCreds = <String, dynamic>{
        'email': email,
        'forename': forename,
        'surname': surname,
        'selectedOption': selectedOption,
        'selectedExpOption': selectedExpOption,
        'attributes' :     {
          "firstName":forename,
          "lastName": surname,
          "email":email,
        }
      };

      final User? newUser = userCredential.user;

      if (newUser != null) {
        await newUser.updateDisplayName('$forename $surname');
        await _timeTrackingUtils.createTrialTimeFlag(newUser);
      }

      // Create a new user document in Firestore
      await db.collection('users').add(userCreds).then((DocumentReference doc) =>
          print('DocumentSnapshot added with ID: ${doc.id}'));
    } catch (e) {
      throw e;
    }
  }


  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  // Inside your updateUserData function
  Future<void> updateUserData(String forename, String surname, String email, String password) async {
    final user = _auth.currentUser;

    if (user != null) {
      // Update user profile in Firebase Authentication
      await user.updateDisplayName('$forename $surname');
      await user.updateEmail(email);

      // Update password if provided
      if (password.isNotEmpty) {
        await user.updatePassword(password);
      }
    }
  }

   // Delete account
  Future<void> deleteAccount(BuildContext context) async {
    final user = _auth.currentUser;

    if (user != null) {
      try {
        // Delete user data from Firestore
        final userDocs = await db.collection('users').where('email', isEqualTo: user.email).get();
        for (final doc in userDocs.docs) {
          await doc.reference.delete();
        }

        // Delete user from Firebase Authentication
        await user.delete();

        // Sign out the user
        await signOut();

        // Navigate to a different screen or show a message
        AppRoutes.generateRoute(
                    RouteSettings(name: AppRoutes.initialLoginAdobeExpressOneContainerScreen),
                  ),
        } catch (e) {
        print('Error deleting account: $e');
        // Handle the error, e.g., show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      }
    } else {
      // Handle the case where there is no authenticated user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No authenticated user found')),
      );
    }
  }


  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('Password reset email sent');
    } catch (e) {
      print(e.toString());
    }
  }

  void showEmailResetDialog(BuildContext context) {
    TextEditingController _emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: TextField(
            controller: _emailController,
            decoration: InputDecoration(hintText: "Enter email"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                sendPasswordResetEmail(_emailController.text);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


}
