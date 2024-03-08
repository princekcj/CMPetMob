import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cmpets/routes/app_routes.dart' as routes;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cmpets/core/app_export.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../auth/Auth_provider.dart';
import '../../auth/facebook.dart';
import '../../auth/google.dart';

class InitialLoginAdobeExpressOneContainerScreen extends StatefulWidget {
  const InitialLoginAdobeExpressOneContainerScreen({Key? key})
      : super(key: key);

  @override
  _InitialLoginAdobeExpressOneContainerScreenState createState() =>
      _InitialLoginAdobeExpressOneContainerScreenState();
}

class _InitialLoginAdobeExpressOneContainerScreenState
    extends State<InitialLoginAdobeExpressOneContainerScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Declare here to maintain state

  @override
  Widget build(BuildContext context) {
    final authService = ProviderContainer().read(authProvider);

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Color(0xFF008C8C),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      ImageConstant.homepagelogo,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible, // Obfuscate the text when not visible
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      // Toggle password visibility
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });

                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await authService.signIn(
                        _emailController.text,
                        _passwordController.text,
                      );
                      Navigator.pushReplacementNamed(context, AppRoutes.barcodeScreen);
                    } catch (e) {
                      print('Sign-in error: $e');
                      // Extract the error message without the code
                      String errorMessage = e.toString();
                      if (e is FirebaseAuthException) {
                        errorMessage = e.message ?? 'An error occurred during sign-in.';
                      }

                      // Show a pop-up alert with the error message
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Sign-in Error'),
                            content: Text('$errorMessage'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    side: BorderSide(color: Colors.grey),
                  ),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // In your widget
                GestureDetector(
                  onTap: () {
                    authService.showEmailResetDialog(context);
                  },
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Adjust the spacing as needed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly space the buttons
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding to the left and right
                    child: SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () async {
                          UserCredential? userCredential = await signInWithGoogle();
                          print("user cred for g is $userCredential");
                          if (userCredential != null) {
                            Navigator.pushReplacementNamed(context, AppRoutes.barcodeScreen);
                          }
                        },
                        child: Image.asset(
                          ImageConstant.google, // Replace with the path to your Facebook icon image
                          height: 36,
                          // You can also specify additional properties like width, alignment, etc.
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.grey,
                    height: 3,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey,
                    height: 3,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.registrationAdobeExpressOneScreen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                side: BorderSide(color: Colors.grey),
              ),
              child: Text('Register Account'),
            ),
          ],
        ),
      ),
    );
  }
}
