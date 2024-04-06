import 'package:cmpets/core/app_export.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../routes/app_routes.dart';

class OnboardingScreen extends StatelessWidget {
  final List<PageViewModel> listPagesViewModel = [
    PageViewModel(
      title: "Welcome to CMPet?",
      body: "Let’s find out how to use our app. ",
      image: Image.asset(ImageConstant.homepagelogo),
    ),
    PageViewModel(
      title: "Firstly",
      body: "Let's create a pet profile so that all your searches are personalized. Simply click on the pets icon at the bottom right and add a new profile.",
      image: Image.asset(ImageConstant.slide3, height: 450),
      decoration: const PageDecoration(
        imagePadding: EdgeInsets.only(top: 100.0),
      ),
    ),
    PageViewModel(
      body: "To use the search simply press magnifying glass icon and press scan barcode.",
      image: Image.asset(ImageConstant.slide4, height: 450),
      decoration: const PageDecoration(
        imagePadding: EdgeInsets.only(top: 100.0),
      ),
    ),
    PageViewModel(
      body: "Looking for a product without a barcode or a single ingredient simply type what you are looking for",
      image: Image.asset(ImageConstant.slide5, height: 450),
      decoration: const PageDecoration(
        imagePadding: EdgeInsets.only(top: 100.0),
      ),
    ),
    PageViewModel(
      body: "It’s as simple as that! To find out more about other features or if you’re ever stuck simply head to Help Centre, and if you require any further assistance, please do not hesitate to reach out to us via email. We’re here to help! 😊",
      image: Image.asset(ImageConstant.slide6, height: 450),
      decoration: const PageDecoration(
        imagePadding: EdgeInsets.only(top: 100.0),
      ),
    ),
    // Add more pages as needed
  ];

  @override
  Widget build(BuildContext context) {
    String? _userId = FirebaseAuth.instance.currentUser?.uid;


    return IntroductionScreen(
      pages: listPagesViewModel,
      showSkipButton: true,
      skip: const Icon(Icons.skip_next),
      next: const Text("Next"),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w700)),
      onDone: () async {
        // Handle action when Done button is pressed
        String _preferencesKey = '$_userId';
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('$_preferencesKey-Onboarded', true);
        Navigator.pushReplacementNamed(context, AppRoutes.barcodeScreen);
      },
      onSkip: () async {
        // Handle action when Skip button is pressed
        String _preferencesKey = '$_userId';
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('$_preferencesKey-Onboarded', true);
        Navigator.pushReplacementNamed(context, AppRoutes.barcodeScreen);

      },
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Color(0xFF008C8C),
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}
