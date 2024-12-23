import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as fs;
import 'package:cmpets/routes/app_routes.dart' as routes;
import 'package:cmpets/widgets/app_bar/custom_app_bar.dart';
import 'package:cmpets/widgets/app_bar/topappbar.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/utils/analytics_utils.dart' as analytics_utils;
import '../../auth/Auth_provider.dart';
import '../../core/utils/color_constant.dart';
import '../../core/utils/image_constant.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_bar/custom_app_drawer.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../services/url_launchers.dart' as launch;
import '../../services/url_launchers.dart';

class MyAccountAdobeExpress1OneScreen extends StatefulWidget {
  const MyAccountAdobeExpress1OneScreen({Key? key}) : super(key: key);

  @override
  _MyAccountAdobeExpress1OneScreenState createState() =>
      _MyAccountAdobeExpress1OneScreenState();
}

class _MyAccountAdobeExpress1OneScreenState
    extends State<MyAccountAdobeExpress1OneScreen> {
  bool isMenuOpen = false;

  TextEditingController _forenameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final authService = ProviderContainer().read(authProvider);
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  final String? userName = FirebaseAuth.instance.currentUser?.displayName;
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  @override
  void initState() {
    super.initState();

    // Fetch user data from Firestore and update the controllers with saved user data
    db.collection("users").doc(user!.uid).get().then((doc) {
        final List<String>? nameParts = userName?.split(' ');

        final String savedForename = nameParts != null && nameParts.length > 0 ? nameParts[0] : '';
        final String savedSurname = nameParts != null && nameParts.length > 1 ? nameParts[1] : '';
        final savedEmail = userEmail
            as String; // Assuming the email field is named 'email'

        _forenameController.text = savedForename;
        _surnameController.text = savedSurname;
        _emailController.text = savedEmail;

        // You might not want to set the password directly for security reasons
        // _passwordController.text = 'Saved Password';

    });
  }

  @override
  Widget build(BuildContext context) {
    analytics_utils.logScreenUsageEvent('Search_ingredient');
    return Scaffold(
      resizeToAvoidBottomInset: false, // fluter 2.x
      endDrawer: CustomDrawer(),
        appBar: CustomTopAppBar(
          Enabled: false,
          onTapArrowLeft: (context) {
            Navigator.pop(context);
          },
          onMenuPressed: toggleMenu,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            children: [
              SizedBox(height: 40),
              TextField(
                controller: _forenameController,
                decoration: InputDecoration(
                  hintText: 'Forename',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      // Handle edit icon button press
                    },
                    icon: Icon(Icons.edit),
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _surnameController,
                decoration: InputDecoration(
                  hintText: 'Surname',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      // Handle edit icon button press
                    },
                    icon: Icon(Icons.edit),
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      // Handle edit icon button press
                    },
                    icon: Icon(Icons.edit),
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Update Password',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      // Handle edit icon button press
                    },
                    icon: Icon(Icons.edit),
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  // Handle save button press
                  final updatedForename = _forenameController.text;
                  final updatedSurname = _surnameController.text;
                  final updatedEmail = _emailController.text;
                  final updatedPassword = _passwordController.text;

                  try {
                    // Call a function to update the user data with the new values
                    await authService.updateUserData(updatedForename, updatedSurname,
                        updatedEmail, updatedPassword);

                    // Show a success message using a SnackBar
                    final snackBar = SnackBar(
                      content: Text('Account details are updated!', style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } catch (error) {
                    if (error is FirebaseAuthException && error.code == 'requires-recent-login') {
                      // Show a SnackBar with red color indicating the user to re-login
                      final snackBar = SnackBar(
                        content: Text('Please re-login as this operation requires recent authentication.',
                            style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.red, // Set the background color to red
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      // Handle other errors if needed
                      print('Error: $error');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  side: BorderSide(color: Colors.grey),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  // Handle sign-out button press
                  await authService.signOut();

                  Navigator.pushNamed(context,
                      AppRoutes.initialLoginAdobeExpressOneContainerScreen);
                },
                child: Text(
                  'Sign out',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                  ),
                ),
              ),
              SizedBox(height: 10), // Add extra space
              TextButton( onPressed: () { 
                 final Uri helpCenterURL = Uri.parse('https://cmpet.co.uk');
                    urlLauncherUtils.launchInBrowser(helpCenterURL); 
              }, 
                         child: Text( 'Request Account Deletion', style: TextStyle( color: Colors.red, fontSize: 10, 
                                                                          ), 
                            ), 
                        )
            ],
          ),
        ),
      extendBody: true,
      floatingActionButton: Container(height: 80.0, width:80.0, child: FittedBox(child: FloatingActionButton(
        backgroundColor: Color(0xFF008C8C), // Set the background color to blue
        child: Image.asset(ImageConstant.searchbutton, width: 40, height: 40),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: ColorConstant.fromHex('#a3ccff'), width: 2.0),
          borderRadius:
          BorderRadius.circular(28.0), // Adjust the border radius as needed
        ),
        onPressed: () {
          // Check if the current route is not already the search route

          if (ModalRoute.of(context)!.settings.name != AppRoutes.barcodeScreen) {
            Navigator.pushReplacement(
              context,
              AppRoutes.generateRoute(
                RouteSettings(name: AppRoutes.barcodeScreen),
              ),
            );
          }

        },
      ),),),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomAppBar(
        height: 100,
        actions: [
          // Additional widgets, if any
        ],
        onButtonPressed: (index) {
          // Handle button press based on index
        },
      ),
    );

  }
}
