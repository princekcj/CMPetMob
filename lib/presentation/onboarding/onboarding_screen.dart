import 'package:cmpets/core/app_export.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

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
      body: "Lets create pet profile so that all your searches are personalised. Simply click on pets icon bottom right and add new profile. ",
      image: Image.asset(ImageConstant.homepagelogo),
    ),
    PageViewModel(
      title: "Welcome to CMPet?",
      body: "To use the search simply press magnifying glass icon and press scan barcode.",
      image: Image.asset(ImageConstant.homepagelogo),
    ),
    PageViewModel(
      title: "Welcome to CMPet?",
      body: "Looking for a product without a barcode or a single ingredient simply type what you are looking for",
      image: Image.asset(ImageConstant.homepagelogo),
    ),
    PageViewModel(
      title: "Welcome to CMPet?",
      body: "Looking for a product without a barcode or a single ingredient simply type what you are looking for",
      image: Image.asset(ImageConstant.homepagelogo),
    ),
    PageViewModel(
      title: "Welcome to CMPet?",
      body: "Thank you for being here and if you ever need any help we are here!",
      image: Image.asset(ImageConstant.homepagelogo),
    ),
    PageViewModel(
      title: "Welcome to CMPet?",
      body: "WHEN ITEM DOESN’T SCAN…",
      image: Image.asset(ImageConstant.homepagelogo),
    ),
    PageViewModel(
      title: "It’s not you…or us.",
      body: "Sometimes barcodes change and national data isn’t updated yet. Don’t worry you can still find your item, just type it in manually.",
      image: Image.asset(ImageConstant.homepagelogo),
    ),
    PageViewModel(
      title: "Welcome to CMPet?",
      body: "Simply type name of product in the search bar and when prompted choose the right one",
      image: Image.asset(ImageConstant.homepagelogo),
    ),
    PageViewModel(
      title: "Welcome to CMPet?",
      body: "All done!",
      image: Image.asset(ImageConstant.homepagelogo),
    ),
    // Add more pages as needed
  ];

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: listPagesViewModel,
      showSkipButton: true,
      skip: const Icon(Icons.skip_next),
      next: const Text("Next"),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w700)),
      onDone: () {
        // Handle action when Done button is pressed
        Navigator.pushReplacementNamed(context, AppRoutes.barcodeScreen);
      },
      onSkip: () {
        // Handle action when Skip button is pressed
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
